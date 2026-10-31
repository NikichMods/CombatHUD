-- SPDX-License-Identifier: MPL-2.0
local UEHelpers = require("UEHelpers")
local Policy = require("policy")
local config = { idleOpacity = 0.20, exitDelay = 1.5, injuredExitDelay = 6.0, fadeSeconds = 1.0 }
local state = Policy.newHealth()
local context = Policy.newContext()
local hud, global, ownerAddress
local entries = {}
local disabled, timerHandle = false, nil
local tickCount, lastMode, lastDamageLog = 19, nil, nil
local input = { controller = nil, keys = {}, pre = {}, hook = false,
    hookFailed = false, edgeFailed = false, lastDevice = nil, lastMode = nil, lastPress = nil }

local function log(message)
    print("[AsterigosCombatHUD] " .. message .. "\n")
end

local function valid(object) return object ~= nil and object:IsValid() end
local function address(object) return valid(object) and tostring(object:GetAddress()) or "none" end
local function name(object) return object:GetFName():ToString() end
local function finite(number)
    return type(number) == "number" and number == number and math.abs(number) < math.huge
end
local function near(a, b) return finite(a) and finite(b) and math.abs(a - b) < 0.00001 end

local function derived(object, expected)
    if not valid(object) then return false end
    local class = object:GetClass()
    for _ = 1, 24 do
        if not valid(class) then return false end
        if name(class) == expected then return true end
        class = class:GetSuperStruct()
    end
    return false
end

local function children(parent, limit)
    assert(derived(parent, "PanelWidget"), "expected PanelWidget")
    local count, result, ordered = parent:GetChildrenCount(), {}, {}
    assert(type(count) == "number" and count >= 0 and count <= limit, "child bound exceeded")
    for index = 0, count - 1 do
        local child = parent:GetChildAt(index)
        assert(derived(child, "Widget") and address(child:GetParent()) == address(parent), "child ownership changed")
        assert(result[name(child)] == nil, "duplicate child names")
        result[name(child)], ordered[#ordered + 1] = child, child
    end
    return result, ordered
end

local function restore()
    local clean = true
    for _, entry in ipairs(entries) do
        if entry.last ~= nil then
            if valid(entry.object) then
                local ok, err = pcall(function()
                    local current = entry.object:GetRenderOpacity()
                    if near(current, entry.last) then
                        entry.object:SetRenderOpacity(entry.original)
                        assert(near(entry.object:GetRenderOpacity(), entry.original), "restore readback mismatch")
                    elseif not near(current, entry.original) then
                        error("native opacity changed: " .. entry.label)
                    end
                end)
                if not ok then
                    clean = false
                    log("Restore skipped for " .. entry.label .. ": " .. tostring(err))
                end
            end
            entry.last = nil
        end
    end
    return clean
end

local function release(reason)
    if not restore() then disabled = true end
    entries, ownerAddress, state, lastMode, lastDamageLog = {}, nil, Policy.newHealth(), nil, nil
    context = Policy.newContext()
    input.controller, input.keys, input.pre = nil, {}, {}
    input.lastDevice, input.lastMode, input.lastPress = nil, nil, nil
    if reason then log("HUD released: " .. reason) end
end

local hpNames = {
    HPBar = true, HPDamageBar = true, HPArrow_Image = true, WarningBar = true,
    HPFrameLine0_Img = true, HPFrameLine1_Img = true,
    HPFrameLine2_Img = true, HPFrameLine3_Img = true
}
local statusNames = { APBar = true, ExpBar = true, UnUsePoint_Image = true, DamageTipList_Panel = true }

local function add(label, object, vital)
    assert(derived(object, "Widget"), "missing target: " .. label)
    for _, entry in ipairs(entries) do
        assert(address(entry.object) ~= address(object), "duplicate target address")
    end
    local original = object:GetRenderOpacity()
    assert(finite(original) and original >= 0 and original <= 1, "invalid opacity: " .. label)
    entries[#entries + 1] = {
        label = label, object = object, original = original, vital = vital,
        skill = label == "right.HUDSkillUMG_BP" or label == "right.HUDActiveSkillUMG_BP",
        -- This branch was native-hidden in the experiment. Never pin its alpha to zero.
        deferred = label == "items.CrystalList_Panel" and near(original, 0)
    }
end

local function bind()
    local left, status, items = hud.LeftBottom_Panel, hud.HUDStatusBarUMG_BP, hud.HUDUseItemUMG_BP
    assert(derived(left, "CanvasPanel") and derived(status, "HUDStatusBarUMG_BP_C") and
        derived(items, "HUDUseItemUMG_BP_C"), "HUD root structure changed")
    assert(address(status:GetParent()) == address(left) and
        address(items:GetParent()) == address(left), "left widget ownership changed")

    local statusMain = status.HPBar:GetParent()
    assert(derived(statusMain, "CanvasPanel") and name(statusMain) == "Main_Panel", "status root changed")
    local statusChildren, statusOrder = children(statusMain, 16)
    assert(#statusOrder == 12, "status child count changed")
    for key in pairs(hpNames) do assert(address(statusChildren[key]) == address(status[key]), "HP binding changed: " .. key) end
    for key in pairs(statusNames) do assert(valid(statusChildren[key]), "status sibling missing: " .. key) end
    for _, child in ipairs(statusOrder) do
        local key = name(child)
        assert(hpNames[key] or statusNames[key], "unexpected status sibling: " .. key)
        add("status." .. key, child, hpNames[key] == true)
    end

    local quick = items.QuickItem0:GetParent()
    assert(derived(quick, "CanvasPanel") and name(quick) == "QuickItem_Panel", "quick item root changed")
    local quickChildren, quickOrder = children(quick, 4)
    assert(#quickOrder == 3, "quick slot count changed")
    for index = 0, 2 do
        local key = "QuickItem" .. index
        assert(derived(items[key], "HUDItemSlotUMG_BP_C") and
            address(quickChildren[key]) == address(items[key]), "quick item slot changed: " .. key)
    end
    local itemRoot = quick:GetParent()
    assert(derived(itemRoot, "CanvasPanel") and name(itemRoot) == "CanvasPanel_0", "item root changed")
    local itemChildren, itemOrder = children(itemRoot, 4)
    assert(#itemOrder == 3 and address(itemChildren.QuickItem_Panel) == address(quick), "item siblings changed")
    assert(derived(itemChildren.CrystalList_Panel, "HorizontalBox"), "keyboard crystal group changed")
    assert(address(itemChildren.HUDCrystalUMG_Pad_BP) == address(items.HUDCrystalUMG_Pad_BP),
        "pad crystal group changed")
    local crystals, crystalOrder = children(itemChildren.CrystalList_Panel, 6)
    assert(#crystalOrder == 4, "keyboard crystal slots changed")
    for index = 0, 3 do
        local key = "KBCrystalSlot" .. index
        assert(address(crystals[key]) == address(items[key]), "keyboard crystal slot changed: " .. key)
    end

    add("items.QuickItem_Panel", quick, true)
    add("items.CrystalList_Panel", itemChildren.CrystalList_Panel, false)
    add("items.HUDCrystalUMG_Pad_BP", items.HUDCrystalUMG_Pad_BP, false)
    add("right.HUDSkillUMG_BP", hud.HUDSkillUMG_BP, false)
    add("right.HUDActiveSkillUMG_BP", hud.HUDActiveSkillUMG_BP, false)
    assert(#entries == 17, "opacity target count changed")
    log("Bound 17 independent HUD targets; keyboard crystals remain native-hidden until available")
end

local function apply(ordinary, vital, skill)
    -- Read and validate all managed values before any write. Native changes never
    -- become the basis for a forced overwrite in this tick.
    local writes = {}
    for _, entry in ipairs(entries) do
        assert(valid(entry.object), "HUD target expired: " .. entry.label)
        local current = entry.object:GetRenderOpacity()
        assert(finite(current), "invalid live opacity: " .. entry.label)
        if entry.deferred and entry.last == nil then
            if near(current, 0) then goto continue end
            local visibility = entry.object:GetVisibility()
            -- Native Hidden/Collapsed must not be treated as an opened bar.
            if visibility == 1 or visibility == 2 then goto continue end
            assert(current > 0 and current <= 1, "unexpected keyboard crystal opacity")
            entry.original, entry.deferred = current, false
            log("Keyboard crystal group became visible; capturing native opacity (visual acceptance pending)")
        end
        local expectedPrevious = entry.last or entry.original
        assert(near(current, expectedPrevious), "native opacity writer conflict: " .. entry.label)
        local factor = entry.vital and vital or (entry.skill and skill or ordinary)
        local desired = entry.original * factor
        if not near(current, desired) then
            writes[#writes + 1] = { entry = entry, value = desired }
        end
        ::continue::
    end
    for _, write in ipairs(writes) do
        local entry = write.entry
        -- Record intent before writing: even a partial failure is recoverable.
        entry.last = write.value
        entry.object:SetRenderOpacity(write.value)
        assert(near(entry.object:GetRenderOpacity(), write.value), "opacity readback mismatch: " .. entry.label)
        if near(write.value, entry.original) then entry.last = nil end
    end
end

local function signature(method)
    local fn = StaticFindObject("/Script/Genesis.GameGlobal:" .. method)
    if not valid(fn) then return false end
    assert((fn:GetFunctionFlags() & 0x2000) ~= 0, method .. " not static")
    local count, objects, returns = 0, 0, 0
    fn:ForEachProperty(function(property)
        local field = property:GetFullName()
        count = count + 1
        if field:match("^ObjectProperty ") and not field:match(":ReturnValue$") then objects = objects + 1 end
        if field:match("^FloatProperty ") and field:match(":ReturnValue$") then returns = returns + 1 end
    end)
    assert(count == 2 and objects == 1 and returns == 1, method .. " signature changed")
    return true
end

local gettersChecked = false
local function refresh()
    local current, count = nil, 0
    for _, candidate in ipairs(FindAllOf("HUDMainUMG_BP_C") or {}) do
        if valid(candidate) and candidate:IsInViewport() then
            current, count = candidate, count + 1
        end
    end
    if count ~= 1 then current = nil end
    if address(current) ~= address(hud) then
        release("viewport changed")
        hud = current
    end
    if not gettersChecked then
        if not signature("GetHP") or not signature("GetMaxHP") then return end
        gettersChecked = true
    end
    if not valid(global) then
        global = FindFirstOf("GameGlobal")
        if not valid(global) then global = StaticFindObject("/Script/Genesis.Default__GameGlobal") end
    end
end

-- Observe the current game's virtual-action mappings. An input callback is only
-- a wake-up; it is never interpreted as Interact without the native key edge.
local interactIds = { "K-Interact", "PC-Joystick-Interact" }
local function readBindings()
    local resolved = {}
    for _, virtualId in ipairs(interactIds) do
        local key = global:GetKeyByVirtualKey(FName(virtualId))
        assert(type(key) == "table" and key.KeyName ~= nil, "invalid FKey from " .. virtualId)
        local value = key.KeyName:ToString()
        assert(type(value) == "string", "invalid FKey name for " .. virtualId)
        if value ~= "None" and value ~= "" then resolved[#resolved + 1] = value end
    end
    input.keys = resolved -- strings only: no borrowed native FKey or array wrappers
end

local function nativeScene()
    if not valid(global) or not valid(hud) then return false end
    if global:GetInputMode(true, false) ~= 0 then return false end
    local left = hud.LeftBottom_Panel
    if not valid(left) then return false end
    local ancestor = left:GetParent()
    if not derived(ancestor, "PanelWidget") then return false end
    local visibility = ancestor:GetVisibility()
    return visibility ~= 1 and visibility ~= 2
end

local function listenerKey(contextParam, targetParam)
    local controller = contextParam and contextParam:get()
    local target = targetParam and targetParam:get()
    if not valid(controller) or not valid(target) then return nil end
    if address(controller) ~= address(input.controller) then return nil end
    return address(target)
end

local function beforePress(contextParam, targetParam)
    if disabled or input.edgeFailed then return end
    local ok, err = pcall(function()
        local key = listenerKey(contextParam, targetParam)
        if key then input.pre[key] = nativeScene() end
    end)
    if not ok then
        input.edgeFailed = true
        log("Interact observer disabled: pre-callback " .. tostring(err))
    end
end

local function afterPress(contextParam, targetParam)
    if disabled or input.edgeFailed then return end
    local ok, err = pcall(function()
        local key = listenerKey(contextParam, targetParam)
        if not key then return end
        local wasScene = input.pre[key]
        input.pre[key] = nil
        if not wasScene or not nativeScene() then return end
        for _, nameOfKey in ipairs(input.keys) do
            local nativeKey = { KeyName = FName(nameOfKey) }
            if input.controller:IsInputKeyDown(nativeKey) and
               input.controller:WasInputKeyJustPressed(nativeKey) then
                local now = UEHelpers.GetGameplayStatics():GetTimeSeconds(hud)
                if finite(now) and now ~= input.lastPress then
                    input.lastPress = now -- once per game frame despite listener fan-out
                    Policy.pressInteract(context, now)
                end
                return
            end
        end
    end)
    if not ok then
        input.edgeFailed = true
        log("Interact observer disabled: post-callback " .. tostring(err))
    end
end

local function installInputHook()
    if input.hook or input.hookFailed then return end
    local path = "/Script/Genesis.GenesisPlayerController:OnActionInputPressed"
    if not valid(StaticFindObject(path)) then return end
    local ok, pre, post = pcall(RegisterHook, path, beforePress, afterPress)
    if ok and type(pre) == "number" and type(post) == "number" then
        input.hook = true
    else
        input.hookFailed = true
        log("Interact observer unavailable: native hook not registered; automatic HUD remains active")
    end
end

local function contextualInput()
    local controller = hud:GetOwningPlayer()
    if not derived(controller, "GenesisPlayerController") then
        input.controller, input.keys = nil, {}
        Policy.cancelSkill(context)
        return false, false
    end
    local ownerChanged = address(controller) ~= address(input.controller)
    if ownerChanged then
        input.controller, input.pre = controller, {}
        input.lastDevice, input.lastMode = nil, nil
        input.lastPress = nil
        Policy.cancelSkill(context)
    end
    local mode = global:GetInputMode(true, false)
    local scene = mode == 0 and nativeScene()
    local device = controller:GetNowInputControllerType()
    if ownerChanged or device ~= input.lastDevice or mode ~= input.lastMode then
        input.lastDevice, input.lastMode = device, mode
        input.pre = {}
        if scene and not input.edgeFailed then
            local ok, err = pcall(readBindings)
            if not ok then
                input.keys = {}
                log("Interact bindings unavailable for this input context: " .. tostring(err))
            end
        end
    end
    if not scene then
        context.lastInteract = nil -- native UI state always wins over manual reveal
        Policy.cancelSkill(context)
        return false, false
    end
    installInputHook()
    return true, controller:GetModifier_SpecialSkill()
end

local function update()
    if disabled then return end
    tickCount = tickCount + 1
    if tickCount >= 20 then tickCount = 0; refresh() end
    if disabled or not valid(hud) then return end
    if not hud:IsInViewport() then
        release("HUD left viewport")
        hud = nil
        return
    end
    local character = hud:GetOwningPlayerPawn()
    if not derived(character, "GenesisCharacter") then
        if ownerAddress ~= nil then release("unready player") end
        return
    end
    if not gettersChecked or not valid(global) then
        if ownerAddress ~= nil then release("HP getter unavailable") end
        return
    end
    if address(character) ~= ownerAddress then
        release("player changed")
        if disabled then return end
        ownerAddress = address(character)
        bind()
        log("Validated player=" .. character:GetFullName())
    end
    local battle = global:GetIsBattleState(character)
    local hp, maxHp = global:GetHP(character), global:GetMaxHP(character)
    local now = UEHelpers.GetGameplayStatics():GetTimeSeconds(hud)
    local ordinary, vital, ordinaryMode, vitalMode, damage = Policy.stepHealth(state, now, battle, hp, maxHp, config)
    if ordinaryMode == "unknown" then error("invalid time, battle or HP getter value") end
    local eligible, held = false, false
    local inputOk, inputErr = pcall(function() eligible, held = contextualInput() end)
    if not inputOk then
        input.keys = {}
        Policy.cancelSkill(context)
        if not input.edgeFailed then log("Contextual input unavailable: " .. tostring(inputErr)) end
        input.edgeFailed = true -- preserve accepted automatic behavior
    end
    local generalGain, skillGain = Policy.stepContext(context, now, held, eligible, config)
    apply(Policy.overlay(ordinary, generalGain), Policy.overlay(vital, generalGain),
        Policy.overlay(ordinary, math.max(generalGain, skillGain)))
    local mode = ordinaryMode .. "/" .. vitalMode
    local logDamage = damage and (lastDamageLog == nil or now - lastDamageLog >= 2 or now < lastDamageLog)
    if mode ~= lastMode or logDamage then
        lastMode = mode
        if damage then lastDamageLog = now end
        log(string.format("state=%s battle=%s hp=%.3f/%.3f opacity=%.3f/%.3f damage=%s",
            mode, tostring(battle), hp, maxHp, ordinary, vital, tostring(damage)))
    end
end

local function disable(reason, cleanup)
    -- Make the timer and input observers inert before attempting fallible cleanup.
    disabled = true
    pcall(log, reason)
    if cleanup then
        local ok, clean = pcall(restore)
        if not ok or not clean then
            pcall(log, "Fail-safe restore incomplete: " .. tostring(clean))
        end
    end
    local handle = timerHandle
    timerHandle = nil -- one cancellation attempt, including when cancellation fails
    if handle ~= nil then
        -- UE4SS 83330635 retains vector indices across callback execution.
        -- Finish all Widget/UFunction calls BEFORE marking this action for removal:
        -- nested ProcessEvent cleanup must not shift that vector during restore.
        local ok, cancelled = pcall(CancelDelayedAction, handle)
        if not ok or cancelled ~= true then
            pcall(log, "Scheduler cancellation failed; callback remains inert: " .. tostring(cancelled))
        end
    end
end

log("Loaded CombatHUD 0.4.1 safe-game-thread candidate; 0.20 idle, 1.5s normal/6.0s injured hold, 1.0s fade, nominal 50ms HP sampling")
if type(LoopInGameThreadWithDelay) ~= "function" or type(CancelDelayedAction) ~= "function" then
    disable("Scheduler unavailable: GameThread delayed-action API required; HUD unchanged", false)
else
    local ok, handle = pcall(LoopInGameThreadWithDelay, 50, function()
        if disabled then return end
        local updated, err = pcall(update)
        if not updated then
            disable("Fail-safe disable: " .. tostring(err), true)
        elseif disabled then
            disable("Fail-safe disable: HUD release could not restore all targets", false)
        end
        -- No return-value cancellation: the API ignores callback results.
    end)
    if ok and math.type(handle) == "integer" and handle >= 0 then
        timerHandle = handle
    else
        disable("Scheduler registration failed; HUD unchanged: " .. tostring(handle), false)
    end
end
