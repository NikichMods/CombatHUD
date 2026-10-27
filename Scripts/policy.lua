local M = {}

function M.new()
    return { quietSince = nil, alpha = 1.0 }
end

function M.step(state, now, battle, config)
    if type(now) ~= "number" or type(battle) ~= "boolean" then
        state.quietSince = nil
        state.alpha, state.target, state.lastTime = 1.0, nil, nil
        return 1.0, "unknown"
    end
    if state.lastTime and now < state.lastTime then
        state.quietSince, state.alpha, state.target = nil, 1.0, nil
    end
    state.lastTime = now
    local target, mode
    if battle then
        state.quietSince = nil
        target, mode = 1.0, "combat"
    else
        if state.quietSince == nil then state.quietSince = now end
        if now - state.quietSince <= config.exitDelay then
            target, mode = 1.0, "hold"
        else
            target, mode = config.idleOpacity, "idle"
        end
    end
    if target ~= state.target then
        state.target, state.from, state.started = target, state.alpha, now
        if mode == "idle" then state.started = state.quietSince + config.exitDelay end
    end
    local progress = math.min(1.0, math.max(0.0, (now - state.started) / config.fadeSeconds))
    -- Smoothstep has no abrupt derivative at either end of the fade.
    progress = progress * progress * (3.0 - 2.0 * progress)
    state.alpha = state.from + (target - state.from) * progress
    if progress == 1.0 then state.alpha = target end
    if state.alpha ~= target then mode = battle and "revealing" or "fading" end
    return state.alpha, mode
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

-- The ordinary HUD follows combat and recent damage. The HP/item group also
-- remains bright while injured and starts its own delay when HP becomes full.
-- Both use the already-accepted fade policy, with no extra timer framework.
function M.newHealth()
    return { ordinary = M.new(), vital = M.new() }
end

local function resetHealth(state)
    state.ordinary, state.vital = M.new(), M.new()
    state.previousHp, state.previousMax, state.lastSampleTime = nil, nil, nil
    state.wasInjured = nil
end

function M.stepHealth(state, now, battle, hp, maxHp, config)
    if not finite(now) or type(battle) ~= "boolean" or not finite(hp) or
       not finite(maxHp) or maxHp <= 0 or hp < 0 or hp > maxHp then
        resetHealth(state)
        return 1.0, 1.0, "unknown", "unknown", false
    end

    -- New game-time generation or changed maximum: acquire a fresh baseline.
    -- Neither is evidence that the character took damage.
    if (state.lastSampleTime and now < state.lastSampleTime) or
       (state.previousMax and maxHp ~= state.previousMax) then
        resetHealth(state)
    end

    local injured = hp < maxHp
    local damage = state.previousHp ~= nil and hp < state.previousHp

    if damage then
        -- Showing the HUD after damage is immediate, even during a fade.
        state.ordinary, state.vital = M.new(), M.new()
    elseif injured and state.wasInjured == false then
        -- A newly incomplete bar is important even without a damage delta.
        state.vital = M.new()
    end

    state.previousHp, state.previousMax = hp, maxHp
    state.lastSampleTime, state.wasInjured = now, injured
    local ordinary, ordinaryMode = M.step(state.ordinary, now, battle, config)
    local vital, vitalMode = M.step(state.vital, now, battle or injured, config)
    return ordinary, vital, ordinaryMode, vitalMode, damage
end

return M
