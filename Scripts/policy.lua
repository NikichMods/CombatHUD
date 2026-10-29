local M = {}

function M.new()
    return { quietSince = nil, alpha = 1.0 }
end

function M.step(state, now, battle, config, exitDelay)
    local delay = exitDelay or config.exitDelay
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
        if now - state.quietSince <= delay then
            target, mode = 1.0, "hold"
        else
            target, mode = config.idleOpacity, "idle"
        end
    end
    if target ~= state.target then
        state.target, state.from, state.started = target, state.alpha, now
        if mode == "idle" then state.started = state.quietSince + delay end
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

-- Ordinary HUD uses the accepted combat/damage clock. HP and quick items
-- instead stay fully bright for a bounded 6s after damage or combat exit
-- when injured. Full healing must not unexpectedly rebrighten a dimmed bar.
function M.newHealth()
    return { ordinary = M.new(), vital = M.new() }
end

local function resetHealth(state)
    state.ordinary, state.vital = M.new(), M.new()
    state.previousHp, state.previousMax, state.lastSampleTime = nil, nil, nil
    state.wasInjured, state.vitalFadeDelay = nil, nil
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
        state.vitalFadeDelay = nil
    elseif injured and state.wasInjured == false then
        -- A newly incomplete bar is important even without a damage delta.
        state.vital = M.new()
        state.vitalFadeDelay = nil
    elseif not injured and state.wasInjured == true and not battle then
        if state.vital.alpha >= 1.0 then
            -- Keep the existing separate 1.5s hold on full healing only
            -- while HP/items were already bright.
            state.vital = M.new()
            state.vitalFadeDelay = nil
        else
            -- If fading already started, finish that same six-second
            -- cycle without a brightness jump or fresh healing timer.
            state.vitalFadeDelay = config.injuredExitDelay
        end
    end

    state.previousHp, state.previousMax = hp, maxHp
    state.lastSampleTime, state.wasInjured = now, injured
    -- A new combat period supersedes an unfinished post-heal fade.
    if battle then state.vitalFadeDelay = nil end
    local ordinary, ordinaryMode = M.step(state.ordinary, now, battle, config)
    local vitalDelay = injured and config.injuredExitDelay or
        (state.vitalFadeDelay or config.exitDelay)
    local vital, vitalMode = M.step(state.vital, now, battle, config, vitalDelay)
    if not injured and vital <= config.idleOpacity then
        state.vitalFadeDelay = nil
    end
    return ordinary, vital, ordinaryMode, vitalMode, damage
end

-- Contextual reveal is an overlay, not a second owner of the combat/HP clocks.
-- It can be composed independently with either accepted baseline opacity.
function M.newContext()
    return { lastInteract = nil, lastTime = nil, skillHeld = false,
        skillReleased = nil, skillArmed = false }
end

function M.pressInteract(state, now)
    if finite(now) and (state.lastTime == nil or now >= state.lastTime) then
        state.lastInteract = now
    end
end

function M.cancelSkill(state)
    state.skillHeld, state.skillReleased, state.skillArmed = false, nil, false
end

local function smoothDown(elapsed, duration)
    if elapsed <= 0 then return 1 end
    if elapsed >= duration then return 0 end
    local p = elapsed / duration
    return 1 - p * p * (3 - 2 * p)
end

function M.stepContext(state, now, held, eligible, config)
    if not finite(now) or type(held) ~= "boolean" or type(eligible) ~= "boolean" then
        state.lastInteract, state.lastTime = nil, nil
        M.cancelSkill(state)
        return 0, 0
    end
    if state.lastTime and now < state.lastTime then
        state.lastInteract = nil
        M.cancelSkill(state)
    end
    state.lastTime = now

    local interact = 0
    if state.lastInteract then
        local elapsed = now - state.lastInteract
        interact = smoothDown(elapsed - config.exitDelay, config.fadeSeconds)
        if interact == 0 then state.lastInteract = nil end
    end

    local skill = 0
    if not eligible then
        M.cancelSkill(state)
    elseif not held then
        if state.skillHeld then state.skillReleased = now end
        state.skillHeld, state.skillArmed = false, true
        if state.skillReleased then
            skill = smoothDown(now - state.skillReleased, config.fadeSeconds)
            if skill == 0 then state.skillReleased = nil end
        end
    elseif state.skillArmed then
        state.skillHeld, state.skillReleased = true, nil
        skill = 1
    end
    return interact, skill
end

function M.overlay(base, gain)
    return base + (1 - base) * gain
end

return M
