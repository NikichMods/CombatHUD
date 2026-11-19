# SPDX-License-Identifier: MPL-2.0
from pathlib import Path

from lupa.lua54 import LuaRuntime


observer = Path(__file__).with_name("main.lua").read_text(encoding="utf-8")
lua = LuaRuntime()
lua.execute("""
messages, scans, cancelled = {}, 0, 0
print = function(message) table.insert(messages, message) end
LoopInGameThreadWithDelay = function(ms, callback)
    assert(ms == 50)
    tick = callback
    return 42
end
CancelDelayedAction = function(handle)
    assert(handle == 42)
    cancelled = cancelled + 1
    return true
end

local nextAddress = 0
function widget(label, parent, alpha, className)
    nextAddress = nextAddress + 1
    local id = nextAddress
    local result = {alpha = alpha or 1, vis = 3, valid = true}
    function result:IsValid() return self.valid end
    function result:GetAddress() return id end
    function result:GetParent() return parent end
    function result:GetFName() return {ToString = function() return label end} end
    function result:GetRenderOpacity() return self.alpha end
    function result:GetVisibility() return self.vis end
    function result:GetClass() return widget(className) end
    function result:GetSuperStruct() return nil end
    return result
end

mode, device, held, playing, inViewport = 0, 4, false, false, false
global = widget("global")
function global:GetInputMode() return mode end
FindFirstOf = function(class) assert(class == "GameGlobal"); return global end
hud = widget("hud")
function hud:IsInViewport() return inViewport end
FindAllOf = function(class)
    assert(class == "HUDMainUMG_BP_C")
    scans = scans + 1
    return {hud}
end
pawn = widget("pawn", nil, nil, "GenesisCharacter")
controller = widget("controller", nil, nil, "GenesisPlayerController")
function hud:GetOwningPlayerPawn() return pawn end
function hud:GetOwningPlayer() return controller end
function controller:GetNowInputControllerType() return device end
function controller:GetModifier_EnchanceItem() return held end

ancestor = widget("ancestor")
hud.LeftBottom_Panel = widget("LeftBottom_Panel", ancestor)
hud.HUDUseItemUMG_BP = widget("items", hud.LeftBottom_Panel)
function makePad()
    local pad = widget("pad", nil, 0.2)
    local main = widget("Main_Panel")
    local equipped = widget("EqipSlot", main)
    pad.Icon_ImageEquip = widget("Icon_ImageEquip", equipped)
    pad.BG_Image = widget("BG_Image", main)
    pad.ReleseBtn = widget("ReleseBtn")
    function pad:IsAnimationPlaying(animation)
        assert(animation == self.ReleseBtn)
        return playing
    end
    for i = 0, 3 do
        local slot = widget("Slot" .. i, main, 0)
        pad["Input_Image" .. i] = widget("Input_Image" .. i, slot)
    end
    hud.HUDUseItemUMG_BP.HUDCrystalUMG_Pad_BP = pad
    return pad
end
pad = makePad()

function lastHas(fragment)
    assert(messages[#messages]:find(fragment, 1, true), messages[#messages])
end
""")
lua.execute(observer)
lua.execute("""
lastHas("START")
tick()
lastHas("WAIT")
inViewport = true
for i = 1, 20 do tick() end
assert(scans == 2)
lastHas("modifier=false")
lastHas("pad=3/0.2000")
lastHas("slot0=3/0.0000")
local count = #messages
tick()
assert(#messages == count)

held, playing = true, true
pad.Input_Image0:GetParent().alpha = 0.5
tick()
lastHas("modifier=true animationPlaying=true")
lastHas("slot0=3/0.5000")
playing = false
pad.Input_Image0:GetParent().alpha = 1
tick()
lastHas("modifier=true animationPlaying=false")
lastHas("slot0=3/1.0000")
held = false
pad.Input_Image0:GetParent().alpha = 0
tick()
lastHas("modifier=false")
lastHas("slot0=3/0.0000")
mode = 1
tick()
lastHas("INELIGIBLE")
mode, device = 0, 1
tick()
lastHas("device=1")
device = 4
tick()
lastHas("STATE")
pad = makePad()
count = #messages
tick()
assert(#messages == count + 1)
""")

# A bad contract stops the observer once, including subsequent callbacks.
lua.execute("""
pad.Input_Image0.valid = false
tick()
lastHas("STOP read contract failed")
assert(cancelled == 1)
local count = #messages
tick()
assert(cancelled == 1 and #messages == count)
""")

# Reinitialize the script against the same fixture and force distinct transitions.
lua.execute("messages, cancelled, pad = {}, 0, makePad()")
lua.execute(observer)
lua.execute("""
for i = 1, 90 do held = not held; tick() end
lastHas("STOP transition log budget exhausted")
assert(#messages == 82 and cancelled == 1)
""")
print("Crystal selector observer mock checks passed")
