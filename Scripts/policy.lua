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

return M
