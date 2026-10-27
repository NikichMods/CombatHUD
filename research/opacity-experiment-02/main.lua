-- SPDX-License-Identifier: MPL-2.0
-- Research-only visual projection; accepted CombatHUD must be disabled in loader config.
-- No health/gameplay/save/Visibility writes. One-time opacity writes per manual mode.
local ID, PREFIX = "combathud-opacity-02", "COMBATHUD_OPACITY"
local active, pending, requested = true, false, nil
local started, nextDiscovery, lastAudit, lastStats = os.time(), 0, 0, 0
local hud, pawnAddress, generation, mode = nil, nil, 0, "baseline"
local entries, guards, parts = {}, {}, {}
local lines, checks, conflicts, waiting = 0, 0, 0, nil
local function emit(event, fields)
    if lines >= 500 then return end
    lines = lines + 1
    print(PREFIX .. " id=" .. ID .. " event=" .. event .. " wall=" .. os.time() .. " " .. (fields or "") .. "\n")
end
local function valid(o) return o ~= nil and o:IsValid() end
local function addr(o) return valid(o) and tostring(o:GetAddress()) or "none" end
local function name(o) return o:GetFName():ToString() end
local function finite(x) return type(x) == "number" and x == x and math.abs(x) < math.huge end
local function near(a,b) return finite(a) and finite(b) and math.abs(a-b) < 0.00001 end
local function derived(o, wanted)
    if not valid(o) then return false end
    local cls = o:GetClass()
    for _ = 1, 24 do
        if not valid(cls) then return false end
        if name(cls) == wanted then return true end
        cls = cls:GetSuperStruct()
    end
    return false
end
local function children(parent, limit)
    assert(derived(parent, "PanelWidget"), "parent is not PanelWidget")
    local count, found, order = parent:GetChildrenCount(), {}, {}
    assert(type(count) == "number" and count <= limit and count >= 0, "child bound exceeded")
    for i = 0, count - 1 do
        local child = parent:GetChildAt(i)
        assert(derived(child,"Widget") and addr(child:GetParent()) == addr(parent), "child ownership mismatch")
        assert(not found[name(child)], "duplicate child name")
        found[name(child)], order[#order+1] = child, child
    end
    return found, order
end
local function snapshot(label, object)
    assert(derived(object,"Widget"), label .. " widget missing")
    local alpha = object:GetRenderOpacity()
    assert(finite(alpha) and alpha >= 0 and alpha <= 1, label .. " invalid original opacity")
    emit("BIND", "label=" .. label .. " name=" .. name(object) .. " class=" .. name(object:GetClass()) ..
        " address=" .. addr(object) .. " parent=" .. addr(object:GetParent()) ..
        " original=" .. alpha .. " visibility=" .. tostring(object:GetVisibility()))
    return {label=label, object=object, original=alpha}
end
local function add(label, object, bright)
    for _, e in ipairs(entries) do assert(addr(e.object) ~= addr(object), "duplicate opacity target") end
    local e = snapshot(label,object)
    e.bright = bright
    entries[#entries+1] = e
end
local function guard(label,object) guards[#guards+1] = snapshot(label,object) end
local function rollback(reason)
    local restored, expired, nativeChanged, failures = 0, 0, 0, 0
    for _, e in ipairs(entries) do
        if e.last ~= nil then
            if not valid(e.object) then expired=expired+1
            else
                local ok, err = pcall(function()
                    local current = e.object:GetRenderOpacity()
                    if near(current,e.last) then
                        -- Restore only while the last observed value is still our own.
                        e.object:SetRenderOpacity(e.original)
                        assert(near(e.object:GetRenderOpacity(),e.original), "restore readback differs")
                        restored=restored+1
                    elseif near(current,e.original) then restored=restored+1
                    else
                        nativeChanged=nativeChanged+1
                        emit("RESTORE_SKIPPED", "label=" .. e.label .. " reason=native-value-changed current=" .. tostring(current))
                    end
                end)
                if not ok then failures=failures+1; emit("RESTORE_ERROR", "label=" .. e.label .. " error=" .. string.format("%q",tostring(err))) end
            end
            e.last=nil
        end
    end
    emit("ROLLBACK", "reason=" .. reason .. " restored=" .. restored .. " expired=" .. expired ..
        " native_changed=" .. nativeChanged .. " failures=" .. failures)
    return failures==0 and nativeChanged==0
end
local function stop(reason)
    if not active then return end
    local clean = rollback(reason)
    emit("STOP", "reason=" .. reason .. " cleanup=" .. tostring(clean) .. " checks=" .. checks .. " conflicts=" .. conflicts)
    active=false
end
local function itemSlot(items, slot, index, quickPanel)
    assert(derived(slot,"HUDItemSlotUMG_BP_C") and addr(slot:GetParent()) == addr(quickPanel), "QuickItem owner mismatch")
    emit("ITEM", "index=" .. index .. " name=" .. name(slot) .. " slot_index=" .. tostring(slot.SlotIndex) ..
        " owner=" .. addr(items) .. " panel=" .. addr(quickPanel) .. " address=" .. addr(slot))
    parts[#parts+1] = snapshot("QuickItem"..index,slot)
    local main = slot.Icon_Image:GetParent()
    assert(derived(main,"CanvasPanel") and name(main)=="MainPanel", "item content panel mismatch")
    local _, order = children(main,8)
    local images, texts = 0, 0
    for _, child in ipairs(order) do
        parts[#parts+1]=snapshot("QuickItem"..index.."."..name(child),child)
        if derived(child,"Image") then images=images+1 end
        if derived(child,"TextBlock") then texts=texts+1 end
    end
    assert(#order==5 and images==4 and texts==1, "unexpected item content topology")
    -- Internal reflected field aliases are observations, not write-target selectors.
    -- Match by address, without assuming FName display spelling equals a Lua key.
    for _, key in ipairs({"Bg_Image","Icon_Image","ValueBg_Image","Key_Image"}) do
        local field, matched=slot[key],false
        for _,child in ipairs(order) do if valid(field) and addr(field)==addr(child) then matched=true end end
        emit("ITEM_FIELD","slot="..index.." field="..key.." address="..addr(field).." matches_child="..tostring(matched))
    end
end
local function bind(current, pawn)
    hud, pawnAddress = current, addr(pawn)
    generation=generation+1
    assert(generation<=4, "HUD generation limit")
    local status,items,left = hud.HUDStatusBarUMG_BP,hud.HUDUseItemUMG_BP,hud.LeftBottom_Panel
    assert(derived(status,"HUDStatusBarUMG_BP_C") and derived(items,"HUDUseItemUMG_BP_C"), "HUD child class mismatch")
    assert(addr(status:GetParent())==addr(left) and addr(items:GetParent())==addr(left), "left ownership mismatch")
    local statusMain=status.HPBar:GetParent()
    local statusChildren,statusOrder=children(statusMain,16)
    assert(#statusOrder==12 and name(statusMain)=="Main_Panel", "status topology changed")
    local hp={HPBar=true,HPDamageBar=true,HPArrow_Image=true,WarningBar=true,
        HPFrameLine0_Img=true,HPFrameLine1_Img=true,HPFrameLine2_Img=true,HPFrameLine3_Img=true}
    for key in pairs(hp) do assert(addr(statusChildren[key])==addr(status[key]), "HP target mismatch") end
    for _,child in ipairs(statusOrder) do add("status."..name(child),child,hp[name(child)]==true) end
    local quick=items.QuickItem0:GetParent()
    assert(derived(quick,"CanvasPanel") and name(quick)=="QuickItem_Panel", "quick panel missing")
    local quickChildren,quickOrder=children(quick,4)
    assert(#quickOrder==3, "unexpected quick slot count")
    for i=0,2 do
        local key="QuickItem"..i
        assert(addr(quickChildren[key])==addr(items[key]), "quick slot reflected identity mismatch")
        itemSlot(items,items[key],i,quick)
    end
    local itemRoot=quick:GetParent()
    assert(derived(itemRoot,"CanvasPanel") and name(itemRoot)=="CanvasPanel_0", "item root mismatch")
    local itemChildren,itemOrder=children(itemRoot,4)
    assert(#itemOrder==3 and addr(itemChildren.QuickItem_Panel)==addr(quick), "item root topology changed")
    assert(derived(itemChildren.CrystalList_Panel,"HorizontalBox"), "keyboard crystal panel missing")
    assert(addr(itemChildren.HUDCrystalUMG_Pad_BP)==addr(items.HUDCrystalUMG_Pad_BP), "pad crystal identity mismatch")
    local crystalChildren,crystalOrder=children(itemChildren.CrystalList_Panel,6)
    assert(#crystalOrder==4, "keyboard crystal count mismatch")
    for i=0,3 do local key="KBCrystalSlot"..i; assert(addr(crystalChildren[key])==addr(items[key]), "keyboard crystal slot mismatch") end
    add("items.QuickItem_Panel",quick,true)
    add("items.CrystalList_Panel",itemChildren.CrystalList_Panel,false)
    add("items.HUDCrystalUMG_Pad_BP",items.HUDCrystalUMG_Pad_BP,false)
    add("right.HUDSkillUMG_BP",hud.HUDSkillUMG_BP,false)
    add("right.HUDActiveSkillUMG_BP",hud.HUDActiveSkillUMG_BP,false)
    guard("LeftBottom_Panel",left)
    guard("HUDStatusBarUMG_BP",status)
    guard("status.Main_Panel",statusMain)
    guard("HUDUseItemUMG_BP",items)
    guard("items.CanvasPanel_0",itemRoot)
    guard("HUD_Panel",left:GetParent())
    guard("hud.Main_Panel",left:GetParent():GetParent())
    emit("READY", "generation="..generation.." pawn="..pawnAddress.." targets="..#entries.." item_parts="..#parts..
        " mode="..mode.." controls=Ctrl-F8:split,Ctrl-F9:all-bright,Ctrl-F10:restore-and-stop synthetic_visual=true")
end
local function discover()
    local current,count=nil,0
    for _,candidate in ipairs(FindAllOf("HUDMainUMG_BP_C") or {}) do
        if valid(candidate) and candidate:IsInViewport() then current,count=candidate,count+1 end
    end
    if count~=1 then return end
    local pawn=current:GetOwningPlayerPawn()
    if not derived(pawn,"GenesisCharacter") then
        local label=valid(pawn) and pawn:GetFullName() or "none"
        if label~=waiting then emit("WAIT_OWNER","pawn="..string.format("%q",label)); waiting=label end
        return
    end
    waiting=nil
    bind(current,pawn)
end
local function inspectConflicts()
    for _,e in ipairs(entries) do
        assert(valid(e.object), "target expired while HUD remains live: "..e.label)
        if e.last~=nil then
            local current=e.object:GetRenderOpacity()
            checks=checks+1
            if not near(current,e.last) then
                conflicts=conflicts+1
                emit("NATIVE_WRITE","label="..e.label.." expected="..e.last.." actual="..tostring(current))
                error("target opacity changed outside experiment")
            end
        end
    end
end
local function apply(newMode)
    inspectConflicts()
    mode=newMode
    for _,e in ipairs(entries) do
        local factor=(mode=="split" and not e.bright) and 0.20 or 1.0
        local expected=e.original*factor
        -- Mark BEFORE mutation so rollback includes a write whose readback fails.
        e.last=expected
        e.object:SetRenderOpacity(expected)
        assert(near(e.object:GetRenderOpacity(),expected), "immediate readback mismatch: "..e.label)
        emit("WRITE","mode="..mode.." label="..e.label.." expected="..expected)
    end
    emit("MODE","mode="..mode.." synthetic_visual=true health_unchanged=true")
end
local function audit()
    local fields={"mode="..mode}
    for _,e in ipairs(guards) do
        assert(valid(e.object),"guard expired: "..e.label)
        fields[#fields+1]=e.label..":"..tostring(e.object:GetRenderOpacity()).."/"..tostring(e.object:GetVisibility())
    end
    local current=table.concat(fields," ")
    if current~=lastAudit then emit("NATIVE_CONTEXT",current); lastAudit=current end
end
local function update()
    if not active then return end
    if requested=="stop" then stop("user-cleanup"); return end
    if os.time()-started>=900 or lines>=460 then stop("bounded-limit"); return end
    if valid(hud) then
        local pawn=hud:GetOwningPlayerPawn()
        if not hud:IsInViewport() or not derived(pawn,"GenesisCharacter") or addr(pawn)~=pawnAddress then
            assert(rollback("owner-change"),"owner-change cleanup incomplete")
            hud,pawnAddress=nil,nil; entries,guards,parts={},{},{}; mode="baseline"
        end
    elseif hud~=nil then
        assert(rollback("HUD-expired"),"expired HUD cleanup incomplete")
        hud,pawnAddress=nil,nil; entries,guards,parts={},{},{}; mode="baseline"
    end
    if not valid(hud) then
        if os.time()<nextDiscovery then return end
        nextDiscovery=os.time()+1
        discover()
        if not valid(hud) then return end
    end
    inspectConflicts()
    if requested then local nextMode=requested; requested=nil; apply(nextMode) end
    audit()
    if os.time()-lastStats>=15 then emit("MONITOR","mode="..mode.." checks="..checks.." conflicts="..conflicts); lastStats=os.time() end
end
emit("START","mode=baseline synthetic_visual_only=true max_seconds=900 interval_ms=50 combat_hud_must_be_disabled=true")
RegisterKeyBind(Key.F8,{ModifierKey.CONTROL},function() if active then requested="split"; emit("CONTROL","request=split") end end)
RegisterKeyBind(Key.F9,{ModifierKey.CONTROL},function() if active then requested="full"; emit("CONTROL","request=full") end end)
RegisterKeyBind(Key.F10,{ModifierKey.CONTROL},function() if active then requested="stop"; emit("CONTROL","request=stop") end end)
LoopAsync(50,function()
    if not active then return true end
    if pending then return false end
    pending=true
    local ok,err=pcall(ExecuteInGameThread,function()
        local success,failure=pcall(update)
        pending=false
        if not success then emit("REJECT","error="..string.format("%q",tostring(failure))); stop("contract-failure") end
    end)
    if not ok then
        pending=false
        emit("REJECT","scope=scheduler error="..string.format("%q",tostring(err)))
        emit("STOP","reason=scheduler-failure cleanup=false action=close-game-to-discard-session-writes")
        active=false
    end
    return false
end)
