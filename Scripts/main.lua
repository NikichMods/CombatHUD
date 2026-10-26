local UEHelpers = require("UEHelpers")
local Policy = require("policy")
local config = { idleOpacity = 0.20, exitDelay = 1.5, fadeSeconds = 1.0 }
local state = Policy.new()
local hud, global, combatFunction
local panels = {}
local pending = false
local lastMode, lastError
local tickCount = 19
local lastCharacterAddress

local function isCharacter(object)
    local class = object:GetClass()
    for _ = 1, 24 do
        if class == nil or not class:IsValid() then return false end
        if class:GetFName():ToString() == "GenesisCharacter" then return true end
        class = class:GetSuperStruct()
    end
    return false
end

local function log(message)
    print("[AsterigosCombatHUD] " .. message .. "\n")
end

local function valid(object)
    return object ~= nil and object:IsValid()
end

local function restore()
    for _, panel in ipairs(panels) do
        if valid(panel) then pcall(function() panel:SetRenderOpacity(1.0) end) end
    end
end

local function refresh()
    local found = FindAllOf("HUDMainUMG_BP_C") or {}
    local current
    for _, candidate in ipairs(found) do
        if valid(candidate) and candidate:IsInViewport() then current = candidate end
    end
    local sameHud = valid(current) and valid(hud) and current:GetAddress() == hud:GetAddress()
    if not sameHud and (valid(current) or valid(hud)) then
        restore()
        hud = current
        panels = {}
        state = Policy.new()
        if valid(hud) then
            for _, name in ipairs({"LeftBottom_Panel", "HUDSkillUMG_BP", "HUDActiveSkillUMG_BP"}) do
                local panel = hud[name]
                if valid(panel) then panels[#panels + 1] = panel end
            end
            log("HUD acquired; target panels=" .. tostring(#panels))
        end
    end
    if not valid(combatFunction) then
        combatFunction = StaticFindObject("/Script/Genesis.GameGlobal:GetIsBattleState")
        if valid(combatFunction) then
            combatFunction:ForEachProperty(function(property)
                log("Battle getter field=" .. property:GetFullName())
            end)
        end
    end
    if not valid(global) then
        global = FindFirstOf("GameGlobal")
        -- Only invoke a default object when reflection explicitly marks the getter static.
        if not valid(global) and valid(combatFunction) and (combatFunction:GetFunctionFlags() & 0x2000) ~= 0 then
            global = StaticFindObject("/Script/Genesis.Default__GameGlobal")
        end
        if valid(global) then log("Battle source=" .. global:GetFullName()) end
    end
end

local function update()
    tickCount = tickCount + 1
    if tickCount >= 20 then
        tickCount = 0
        refresh()
    end
    if not valid(hud) then return end
    if #panels ~= 3 or not valid(global) or not valid(combatFunction) then
        restore()
        return
    end
    local character = hud:GetOwningPlayerPawn()
    if not valid(character) or not isCharacter(character) then
        restore()
        state = Policy.new()
        return
    end
    local characterAddress = character:GetAddress()
    if characterAddress ~= lastCharacterAddress then
        lastCharacterAddress = characterAddress
        state = Policy.new()
        log("Validated player=" .. character:GetFullName())
    end
    local battle = global:GetIsBattleState(character)
    if type(battle) ~= "boolean" then error("Battle getter did not return a boolean") end
    local now = UEHelpers.GetGameplayStatics():GetTimeSeconds(hud)
    local alpha, mode = Policy.step(state, now, battle, config)
    -- Child opacity multiplies the game's parent opacity; visibility and native
    -- menu/cutscene hiding remain under the game's control.
    for _, panel in ipairs(panels) do
        if valid(panel) then panel:SetRenderOpacity(alpha) end
    end
    if mode ~= lastMode then
        lastMode = mode
        log(string.format("state=%s battle=%s opacity=%.3f", mode, tostring(battle), alpha))
    end
    if lastError then log("Recovered"); lastError = nil end
end

log("Loaded; idle opacity=0.20, exit delay=1.5s, fade=1.0s")
LoopAsync(50, function()
    if not pending then
        pending = true
        ExecuteInGameThread(function()
            local ok, err = pcall(update)
            if not ok then
                restore()
                state = Policy.new()
                if tostring(err) ~= lastError then
                    lastError = tostring(err)
                    log("Keeping HUD fully visible after error: " .. lastError)
                end
            end
            pending = false
        end)
    end
    return false
end)
