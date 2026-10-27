-- SPDX-License-Identifier: MPL-2.0
-- Research only. No host writes, damage hooks, synthetic health or visibility changes.
local UEHelpers = require("UEHelpers")
local ID, PREFIX = "combathud-hp-readonly-02", "COMBATHUD_HP_PROBE"
local active, pending, lines = true, false, 0
local started, nextDiscovery, heartbeat = os.time(), 0, 0
local hud, global, previous, generation, samples = nil, nil, nil, 0, 0
local fullSeen, partialSeen, recoverySeen = false, false, false
local lastWaitingOwner
local checkedBindings, lastSourceHud = false, nil
local function emit(event, fields)
    if lines >= 400 then active = false; return end
    lines = lines + 1
    print(PREFIX .. " id=" .. ID .. " event=" .. event .. " wall=" .. os.time() .. " " .. (fields or "") .. "\n")
end
local function stop(reason)
    if not active then return end
    emit("STOP", "reason=" .. reason .. " samples=" .. samples .. " full_seen=" .. tostring(fullSeen) ..
        " partial_seen=" .. tostring(partialSeen) .. " recovery_seen=" .. tostring(recoverySeen))
    active = false
end
local function valid(o) return o ~= nil and o:IsValid() end
local function addr(o) return valid(o) and tostring(o:GetAddress()) or "none" end
local function name(o) return o:GetFName():ToString() end
local function derived(o, expected)
    if not valid(o) then return false end
    local cls = o:GetClass()
    for _ = 1, 24 do
        if not valid(cls) then return false end
        if name(cls) == expected then return true end
        cls = cls:GetSuperStruct()
    end
    return false
end
local function finite(n) return type(n) == "number" and n == n and math.abs(n) < math.huge end
local function widget(label, o)
    assert(derived(o, "Widget"), label .. " is not a valid Widget")
    local alpha, visibility = o:GetRenderOpacity(), o:GetVisibility()
    assert(finite(alpha), label .. " opacity is not finite")
    emit("WIDGET", "generation=" .. generation .. " label=" .. label .. " name=" .. name(o) ..
        " class=" .. name(o:GetClass()) .. " address=" .. addr(o) .. " parent=" .. addr(o:GetParent()) ..
        " opacity=" .. tostring(alpha) .. " visibility=" .. tostring(visibility))
end
local function signature(method)
    local path = "/Script/Genesis.GameGlobal:" .. method
    local fn = StaticFindObject(path)
    assert(valid(fn), "missing " .. path)
    local flags = fn:GetFunctionFlags()
    emit("FUNCTION", "path=" .. path .. " flags=" .. tostring(flags))
    assert((flags & 0x2000) ~= 0, method .. " is not static")
    local count, objects, returns = 0, 0, 0
    fn:ForEachProperty(function(p)
        local field = p:GetFullName()
        emit("FIELD", "method=" .. method .. " field=" .. string.format("%q", field))
        count = count + 1
        if field:match("^ObjectProperty ") and not field:match(":ReturnValue$") then objects = objects + 1 end
        if field:match("^FloatProperty ") and field:match(":ReturnValue$") then returns = returns + 1 end
    end)
    assert(count == 2 and objects == 1 and returns == 1, method .. " unexpected reflected signature")
end
local hpNames = {"HPBar", "HPDamageBar", "HPArrow_Image", "WarningBar",
    "HPFrameLine0_Img", "HPFrameLine1_Img", "HPFrameLine2_Img", "HPFrameLine3_Img"}
local function hierarchy()
    local status, left, items = hud.HUDStatusBarUMG_BP, hud.LeftBottom_Panel, hud.HUDUseItemUMG_BP
    assert(derived(status, "HUDStatusBarUMG_BP_C"), "status widget mismatch")
    assert(derived(left, "CanvasPanel"), "left panel mismatch")
    assert(addr(status:GetParent()) == addr(left) and addr(items:GetParent()) == addr(left), "left owner mismatch")
    local main = status.HPBar:GetParent()
    assert(derived(main, "CanvasPanel") and name(main) == "Main_Panel", "HP parent mismatch")
    local root = main:GetParent()
    assert(derived(root, "CanvasPanel") and name(root) == "CanvasPanel_0", "status root mismatch")
    for _, entry in ipairs({{"status", status}, {"left", left}, {"items", items}, {"status-main", main},
        {"status-root", root}, {"hud-parent", left:GetParent()}}) do widget(entry[1], entry[2]) end
    for _, key in ipairs(hpNames) do
        local child = status[key]
        assert(derived(child, "Widget") and addr(child:GetParent()) == addr(main), key .. " parent mismatch")
        widget(key, child)
    end
    for _, key in ipairs({"APBar", "ExpBar", "UnUsePoint_Image"}) do
        local child = status[key]
        assert(derived(child, "Widget") and addr(child:GetParent()) == addr(main), key .. " parent mismatch")
        widget(key, child)
    end
    local count = main:GetChildrenCount()
    assert(type(count) == "number" and count >= 1 and count <= 24, "unexpected status child count")
    local found = {}
    for index = 0, count - 1 do
        local child = main:GetChildAt(index)
        assert(derived(child, "Widget") and addr(child:GetParent()) == addr(main), "child enumeration mismatch")
        assert(not found[name(child)], "ambiguous sibling name")
        found[name(child)] = child
        emit("SIBLING", "index=" .. index .. " name=" .. name(child) .. " address=" .. addr(child))
    end
    for _, key in ipairs(hpNames) do assert(addr(found[key]) == addr(status[key]), key .. " lookup identity mismatch") end
    for _, key in ipairs({"APBar", "ExpBar", "UnUsePoint_Image"}) do
        assert(addr(found[key]) == addr(status[key]), key .. " lookup identity mismatch")
    end
    local tips = found.DamageTipList_Panel
    assert(derived(tips, "CanvasPanel"), "damage tips panel missing")
    assert(addr(status.TipItem_0:GetParent()) == addr(tips), "damage tip owner mismatch")
    widget("DamageTipList_Panel", tips)
    emit("STRUCTURE_OK", "generation=" .. generation .. " child_count=" .. count .. " hp_layers=8 sibling_lookup=exact-name-and-parent")
end
local function discover()
    local found = FindAllOf("HUDMainUMG_BP_C") or {}
    local chosen, count = nil, 0
    for _, candidate in ipairs(found) do
        if valid(candidate) and candidate:IsInViewport() then chosen, count = candidate, count + 1 end
    end
    if count > 1 then return false end
    if not chosen then return false end
    hud = chosen
    if not checkedBindings then
        signature("GetHP")
        signature("GetMaxHP")
        global = FindFirstOf("GameGlobal")
        if not valid(global) then global = StaticFindObject("/Script/Genesis.Default__GameGlobal") end
        assert(valid(global), "GameGlobal invocation object unavailable")
        checkedBindings = true
    end
    if lastSourceHud ~= addr(hud) then
        emit("SOURCE", "hud=" .. addr(hud) .. " global=" .. string.format("%q", global:GetFullName()))
        lastSourceHud = addr(hud)
    end
    return true
end
local function update()
    if not active then return end
    if os.time() - started >= 900 then stop("15-minute-limit"); return end
    if not valid(hud) then
        if os.time() < nextDiscovery then return end
        nextDiscovery = os.time() + 1
        previous = nil
        if not discover() then return end
    end
    if not hud:IsInViewport() then previous = nil; hud = nil; return end
    local pawn = hud:GetOwningPlayerPawn()
    if not valid(pawn) or not derived(pawn, "GenesisCharacter") then
        local waiting = valid(pawn) and pawn:GetFullName() or "none"
        if waiting ~= lastWaitingOwner then
            emit("WAIT_OWNER", "action=skip-unready-owner pawn=" .. string.format("%q", waiting))
            lastWaitingOwner = waiting
        end
        previous, hud = nil, nil
        return
    end
    lastWaitingOwner = nil
    local key = addr(hud) .. ":" .. addr(pawn)
    if not previous or previous.key ~= key then
        generation = generation + 1
        assert(generation <= 4, "generation limit exceeded")
        emit("OWNER", "generation=" .. generation .. " pawn=" .. string.format("%q", pawn:GetFullName()) .. " address=" .. addr(pawn))
        hierarchy()
        previous = { key = key }
    end
    local now = UEHelpers.GetGameplayStatics():GetTimeSeconds(hud)
    assert(finite(now), "invalid game time")
    if previous.hp == nil then emit("BEFORE_READ", "generation=" .. generation .. " method=GetHP") end
    local hp = global:GetHP(pawn)
    if previous.hp == nil then emit("AFTER_READ", "method=GetHP result_type=" .. type(hp)); emit("BEFORE_READ", "method=GetMaxHP") end
    local max = global:GetMaxHP(pawn)
    if previous.hp == nil then emit("AFTER_READ", "method=GetMaxHP result_type=" .. type(max)) end
    assert(finite(hp) and finite(max) and max > 0 and hp >= 0 and hp <= max, "invalid HP getter values")
    samples = samples + 1
    local isFull = hp == max
    fullSeen, partialSeen = fullSeen or isFull, partialSeen or hp < max
    if previous.hp and previous.hp < previous.max and isFull then recoverySeen = true end
    if hp ~= previous.hp or max ~= previous.max or now < (previous.time or now) then
        local delta = previous.hp and hp - previous.hp or 0
        emit("HP", "generation=" .. generation .. " game_time=" .. tostring(now) .. " hp=" .. tostring(hp) ..
            " max=" .. tostring(max) .. " hp_type=" .. type(hp) .. " max_type=" .. type(max) ..
            " full=" .. tostring(isFull) .. " delta=" .. tostring(delta) .. " baseline=" .. tostring(previous.hp == nil))
    end
    previous.hp, previous.max, previous.time = hp, max, now
    if os.time() - heartbeat >= 30 then
        emit("ALIVE", "samples=" .. samples .. " game_time=" .. tostring(now) .. " hp=" .. tostring(hp) .. " max=" .. tostring(max))
        heartbeat = os.time()
    end
    if fullSeen and partialSeen and recoverySeen then stop("full-partial-recovered-observed") end
end
emit("START", "mode=read-only synthetic=false interval_ms=50 discovery_ms=1000 max_seconds=900 max_lines=400")
LoopAsync(50, function()
    if not active then return true end
    if pending then return false end
    pending = true
    local ok, failure = pcall(ExecuteInGameThread, function()
        local success, err = pcall(update)
        pending = false
        if not success then emit("REJECT", "action=disable-probe error=" .. string.format("%q", tostring(err))); stop("contract-failure") end
    end)
    if not ok then pending = false; emit("REJECT", "action=disable-probe error=" .. string.format("%q", tostring(failure))); stop("scheduler-failure") end
    return false
end)
