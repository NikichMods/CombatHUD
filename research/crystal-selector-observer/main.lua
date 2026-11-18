-- SPDX-License-Identifier: MPL-2.0
-- Standalone UE4SS research observer. Samples the live widgets without writing them.
local tag = "[CrystalSelectorObserver] "
local running, handle = true, nil
local hud, global
local ticksUntilDiscovery = 0
local previous, records = nil, 0

local function log(message)
    print(tag .. message .. "\n")
end

local function stop(reason)
    running = false
    log("STOP " .. reason)
    if handle ~= nil then
        local ok, cancelled = pcall(CancelDelayedAction, handle)
        handle = nil
        if not ok or cancelled ~= true then log("Cancellation failed; callback inert") end
    end
end

local function valid(object)
    return object ~= nil and object:IsValid()
end

local function name(object)
    return object:GetFName():ToString()
end

local function isA(object, className)
    if not valid(object) then return false end
    local class = object:GetClass()
    for _ = 1, 24 do
        if not valid(class) then return false end
        if name(class) == className then return true end
        class = class:GetSuperStruct()
    end
    return false
end

local function address(object)
    return object:GetAddress()
end

local function discover()
    local current, count = nil, 0
    for _, candidate in ipairs(FindAllOf("HUDMainUMG_BP_C") or {}) do
        if valid(candidate) and candidate:IsInViewport() then
            current, count = candidate, count + 1
        end
    end
    hud = count == 1 and current or nil
    if not valid(global) then
        global = FindFirstOf("GameGlobal")
        if not valid(global) then global = StaticFindObject("/Script/Genesis.Default__GameGlobal") end
    end
end

local function emit(key, detail)
    if key == previous then return end
    previous = key
    records = records + 1
    log(detail)
    if records == 80 then stop("transition log budget exhausted") end
end

local function observe()
    if ticksUntilDiscovery == 0 then
        discover()
        ticksUntilDiscovery = 20
    end
    ticksUntilDiscovery = ticksUntilDiscovery - 1
    if not valid(hud) or not hud:IsInViewport() or not valid(global) then
        return emit("no-hud", "WAIT no unique viewport HUD or GameGlobal")
    end

    local pawn, controller = hud:GetOwningPlayerPawn(), hud:GetOwningPlayer()
    if not isA(pawn, "GenesisCharacter") or not isA(controller, "GenesisPlayerController") then
        return emit("no-owner", "WAIT no gameplay owner")
    end
    local mode = global:GetInputMode(true, false)
    local device = controller:GetNowInputControllerType()
    assert(type(mode) == "number" and type(device) == "number", "invalid input context")
    local context = string.format("hud=%s pawn=%s controller=%s mode=%d device=%d",
        address(hud), address(pawn), address(controller), mode, device)
    local left = hud.LeftBottom_Panel
    if not valid(left) then return emit("no-left", "WAIT no left HUD") end
    local ancestor = left:GetParent()
    if not valid(ancestor) then return emit("no-ancestor", "WAIT no native HUD ancestor") end
    local ancestorVisibility = ancestor:GetVisibility()
    context = context .. " ancestorVis=" .. tostring(ancestorVisibility)
    -- Reflected EGenesisInputControllerType values: DS4 through Switch.
    if mode ~= 0 or device < 2 or device > 5 or ancestorVisibility == 1 or ancestorVisibility == 2 then
        return emit(context, "INELIGIBLE " .. context)
    end

    local items = hud.HUDUseItemUMG_BP
    if not valid(items) then return emit("no-items", "WAIT item HUD unavailable") end
    local itemParent = items:GetParent()
    assert(valid(itemParent) and address(itemParent) == address(left), "item HUD owner changed")
    local pad = items.HUDCrystalUMG_Pad_BP
    if not valid(pad) then return emit("no-pad", "WAIT pad widget unavailable") end

    local bg, equippedImage, animation = pad.BG_Image, pad.Icon_ImageEquip, pad.ReleseBtn
    assert(valid(bg) and valid(equippedImage) and valid(animation), "missing pad widget bindings")
    local main, equipped = bg:GetParent(), equippedImage:GetParent()
    assert(valid(main) and name(main) == "Main_Panel" and valid(equipped) and name(equipped) == "EqipSlot",
        "pad panel structure changed")
    local equippedParent = equipped:GetParent()
    assert(valid(equippedParent) and address(equippedParent) == address(main), "equipped slot owner changed")
    local modifier = controller:GetModifier_EnchanceItem()
    local playing = pad:IsAnimationPlaying(animation)
    assert(type(modifier) == "boolean" and type(playing) == "boolean", "invalid native state")
    local key = string.format("%s pad=%s modifier=%s animationPlaying=%s",
        context, address(pad), tostring(modifier), tostring(playing))
    local detail = "STATE " .. key

    local function read(label, widget)
        local vis, alpha = widget:GetVisibility(), widget:GetRenderOpacity()
        assert(type(vis) == "number" and type(alpha) == "number" and alpha >= 0 and alpha <= 1,
            "invalid widget state: " .. label)
        local bucket = alpha <= 0.001 and "zero" or (alpha >= 0.999 and "one" or "partial")
        key = key .. string.format(" %s=%d/%s", label, vis, bucket)
        detail = detail .. string.format(" %s=%d/%.4f", label, vis, alpha)
    end

    read("pad", pad)
    read("main", main)
    read("equip", equipped)
    for index = 0, 3 do
        local image = pad["Input_Image" .. index]
        assert(valid(image), "missing pad input image " .. index)
        local slot = image:GetParent()
        assert(valid(slot) and name(slot) == "Slot" .. index, "pad slot structure changed")
        local slotParent = slot:GetParent()
        assert(valid(slotParent) and address(slotParent) == address(main), "pad slot owner changed")
        read("slot" .. index, slot)
        read("glyph" .. index, image)
    end
    emit(key, detail)
end

if type(LoopInGameThreadWithDelay) ~= "function" or type(CancelDelayedAction) ~= "function" then
    stop("GameThread scheduler unavailable")
else
    local ok, result = pcall(LoopInGameThreadWithDelay, 50, function()
        if not running then return end
        local sampled, failure = pcall(observe)
        if not sampled then stop("read contract failed: " .. tostring(failure)) end
    end)
    if ok and math.type(result) == "integer" and result >= 0 then
        handle = result
        log("START nominalMs=50 discoveryTicks=20 recordLimit=80")
    else
        stop("scheduler registration failed: " .. tostring(result))
    end
end
