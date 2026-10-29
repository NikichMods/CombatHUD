from pathlib import Path

from lupa.lua54 import LuaRuntime


project = Path(__file__).resolve().parents[1]
root = project / "Scripts"
assert f"Loaded CombatHUD {(project / 'VERSION').read_text().strip()}" in (root / "main.lua").read_text(), "runtime VERSION/log identity mismatch"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().policySource = (root / "policy.lua").read_text()
fixture = '''
package.preload.policy = function() return assert(load(policySource))() end
now, fighting, hp, maxHp, getterCalls = 0, false, 100, 100, 0
skillHeld, inputMode, inputDevice = false, 0, 4
deviceGetterCalls = 0
keysDown, keysEdge, keyMap = {}, {}, {
    ["K-Interact"] = "F", ["PC-Joystick-Interact"] = "Gamepad_FaceButton_Top" }
wrongPawn, rejectGetters = false, false
local uid = 0
local function cls(name, parent)
    local c = { id = name, parent = parent }
    c.IsValid = function() return true end
    c.GetFName = function() return { ToString = function() return name end } end
    c.GetSuperStruct = function() return parent end
    return c
end
local widget = cls("Widget")
local panel = cls("PanelWidget", widget)
local canvas = cls("CanvasPanel", panel)
local horizontal = cls("HorizontalBox", panel)
local statusClass = cls("HUDStatusBarUMG_BP_C", widget)
local itemsClass = cls("HUDUseItemUMG_BP_C", widget)
local slotClass = cls("HUDItemSlotUMG_BP_C", widget)
local hudClass = cls("HUDMainUMG_BP_C", widget)
local pawnClass = cls("GenesisCharacter")
local hildaClass = cls("hilda_BP_C", pawnClass)
local controllerClass = cls("GenesisPlayerController")
local function mock(class, label, parent, alpha)
    uid = uid + 1
    local o = { id = uid, class = class, label = label, parent = parent, alpha = alpha or 1, kids = {}, visibility = 3 }
    if parent then table.insert(parent.kids, o) end
    o.IsValid = function() return o.alive ~= false end
    o.GetAddress = function() return o.id end
    o.GetFName = function() return { ToString = function() return label end } end
    o.GetClass = function() return class end
    o.GetParent = function() return parent end
    o.GetFullName = function() return label end
    o.GetChildrenCount = function() return #o.kids end
    o.GetChildAt = function(self, index) return o.kids[index + 1] end
    o.GetRenderOpacity = function() return o.alpha end
    o.SetRenderOpacity = function(self, alpha) o.alpha = alpha; o.writes = (o.writes or 0) + 1 end
    o.GetVisibility = function() return o.visibility end
    return o
end
player = mock(hildaClass, "hilda")
controller = mock(controllerClass, "controller")
listener = mock(widget, "listener")
controller.GetModifier_SpecialSkill = function() return skillHeld end
controller.GetNowInputControllerType = function(self)
    assert(self == controller, "input controller getter called on foreign owner")
    deviceGetterCalls = deviceGetterCalls + 1
    return inputDevice
end
controller.IsInputKeyDown = function(self, key) return keysDown[key.KeyName] == true end
controller.WasInputKeyJustPressed = function(self, key) return keysEdge[key.KeyName] == true end
getters = mock(cls("GameGlobal"), "global")
getters.GetInputMode = function() return inputMode end
getters.GetNowInputControllerType = function()
    error("GetNowInputControllerType belongs to GenesisPlayerController, not GameGlobal")
end
getters.GetKeyByVirtualKey = function(self, virtualId)
    return {KeyName={ToString=function() return keyMap[virtualId] or "None" end}}
end
getters.GetIsBattleState = function(self, who)
    assert(who == player, "foreign pawn passed to battle getter")
    return fighting
end
getters.GetHP = function(self, who)
    assert(who == player, "foreign pawn passed to HP getter")
    getterCalls = getterCalls + 1
    if rejectGetters then error("broken native getter") end
    return hp
end
getters.GetMaxHP = function(self, who)
    assert(who == player, "foreign pawn passed to maximum HP getter")
    return maxHp
end
hud = mock(hudClass, "HUDMainUMG_BP")
hud.IsInViewport = function() return hud.visible ~= false end
hud.GetOwningPlayerPawn = function() if wrongPawn then return mock(widget, "DefaultPawn") end return player end
hud.GetOwningPlayer = function() return controller end
menu = mock(canvas, "HUD_Panel", hud)
left = mock(canvas, "LeftBottom_Panel", menu)
hud.LeftBottom_Panel = left
status = mock(statusClass, "HUDStatusBarUMG_BP", left)
hud.HUDStatusBarUMG_BP = status
statusMain = mock(canvas, "Main_Panel", status)
local statusLabels = {
    "HPBar", "HPDamageBar", "HPArrow_Image", "WarningBar", "HPFrameLine0_Img", "HPFrameLine1_Img",
    "HPFrameLine2_Img", "HPFrameLine3_Img", "APBar", "ExpBar", "UnUsePoint_Image", "DamageTipList_Panel"
}
for _, label in ipairs(statusLabels) do status[label] = mock(widget, label, statusMain) end
items = mock(itemsClass, "HUDUseItemUMG_BP", left)
hud.HUDUseItemUMG_BP = items
itemRoot = mock(canvas, "CanvasPanel_0", items)
quick = mock(canvas, "QuickItem_Panel", itemRoot)
for i = 0, 2 do items["QuickItem" .. i] = mock(slotClass, "QuickItem" .. i, quick) end
keyboard = mock(horizontal, "CrystalList_Panel", itemRoot, 0)
keyboard.visibility = 2
for i = 0, 3 do items["KBCrystalSlot" .. i] = mock(widget, "KBCrystalSlot" .. i, keyboard) end
pad = mock(widget, "HUDCrystalUMG_Pad_BP", itemRoot)
items.HUDCrystalUMG_Pad_BP = pad
hud.HUDSkillUMG_BP = mock(widget, "HUDSkillUMG_BP", menu)
hud.HUDActiveSkillUMG_BP = mock(widget, "HUDActiveSkillUMG_BP", menu)

local function functionObject(method)
    return {
        IsValid = function() return true end,
        GetFunctionFlags = function() return 0x2000 end,
        ForEachProperty = function(self, f)
            f({GetFullName = function() return "ObjectProperty /Script/Genesis.GameGlobal:" .. method .. ":Character" end})
            f({GetFullName = function() return "FloatProperty /Script/Genesis.GameGlobal:" .. method .. ":ReturnValue" end})
        end
    }
end
function FindAllOf() return {hud} end
function FindFirstOf() return getters end
function StaticFindObject(path)
    if path:match("OnActionInputPressed$") then return functionObject("Pressed") end
    local method = path:match("GameGlobal:(.+)$")
    if method then return functionObject(method) end
    return getters
end
function LoopAsync(ms, fn) assert(ms == 50); callback = fn end
function RegisterHook(path, before, after)
    assert(path:match("OnActionInputPressed$"))
    onPressBefore, onPressAfter = before, after
    return 1,2
end
function FName(value) return value end
function ExecuteInGameThread(fn) fn() end
package.preload.UEHelpers = function()
    return {GetGameplayStatics = function() return {GetTimeSeconds = function() return now end} end}
end
function tick(t) now=t; callback() end
function press(key)
    assert(onPressBefore and onPressAfter, "native key observer hook missing")
    keysDown[key], keysEdge[key] = true, true
    local c = {get=function() return controller end}
    local target = {get=function() return listener end}
    onPressBefore(c,target)
    onPressAfter(c,target)
    onPressBefore(c,target); onPressAfter(c,target) -- listener fan-out in same frame
    keysEdge[key] = false
end
function releaseKey(key) keysDown[key]=false end
function nearly(a, b) return math.abs(a - b) < .00001 end
function check(ordinary, vital)
    for _,child in ipairs(statusMain.kids) do
        local special = child.label:match("^HP") or child.label == "WarningBar"
        assert(nearly(child.alpha, special and vital or ordinary), child.label .. " opacity " .. child.alpha)
    end
    assert(nearly(quick.alpha, vital), "quick items")
    assert(nearly(pad.alpha, ordinary), "pad crystals")
    assert(nearly(hud.HUDSkillUMG_BP.alpha, skillExpected or ordinary), "right skills")
    assert(nearly(hud.HUDActiveSkillUMG_BP.alpha, skillExpected or ordinary), "right active skills")
    assert(nearly(keyboard.alpha, keyboardExpected or 0), "keyboard group native baseline changed")
    assert(nearly(left.alpha, 1), "common left ancestor changed")
    assert(nearly(menu.alpha, menuExpected or 1), "native menu ancestor changed")
end
'''
lua.execute(fixture)

lua.execute((root / "main.lua").read_text())
lua.execute('''
tick(0.05)
check(1, 1)
assert(getterCalls == 1)
tick(3)
check(.2, .2)
hp = 70; tick(3.1); check(1, 1)
tick(5.6); check(.2, 1)
hp = 100; tick(6); check(.2, 1)
tick(8.5); check(.2, .2)
fighting = true; tick(8.6) -- ordinary battle reveal is the accepted 1s transition
tick(9.6); check(1, 1)
fighting = false; tick(10); check(1, 1)
tick(12.7); check(.2, .2)
-- Native menu controls a higher ancestor; child opacity must not reassert it.
menu.alpha, menu.visibility, menuExpected = .5, 2, .5
tick(12.8); check(.2, .2)
menu.alpha, menu.visibility, menuExpected = 1, 3, 1
tick(12.9); check(.2, .2)
-- The native-hidden keyboard branch must not be written to or frozen at zero.
assert(not keyboard.writes)
keyboard.alpha, keyboard.visibility = 1, 3
tick(13.0)
assert(nearly(keyboard.alpha, .2), "newly available keyboard crystals should adopt native baseline")
-- An invalid pawn restores only managed child targets, no native gameplay call.
wrongPawn=true; tick(13.1)
for _,child in ipairs(statusMain.kids) do assert(nearly(child.alpha,1), "release missed "..child.label) end
assert(nearly(quick.alpha, 1) and nearly(pad.alpha, 1) and nearly(keyboard.alpha,1))
assert(nearly(menu.alpha,1) and nearly(left.alpha,1))
wrongPawn=false; hp=60; keyboardExpected=1
tick(13.2); check(1,1) -- first partial sample of new pawn generation
''')
lua.execute('''
keyboardExpected=.2; tick(15.8); check(.2,1)
-- Native writer conflict triggers fail-safe; its new value must survive.
pad.alpha = .7
tick(15.9)
assert(nearly(pad.alpha,.7), "native value overwritten after conflict")
assert(nearly(quick.alpha,1), "owned vital group not restored")
for _,child in ipairs(statusMain.kids) do assert(nearly(child.alpha,1), "owned status not restored") end
assert(callback()==true, "mod should stop after unexpected native writer")
''')

runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.globals().policySource = (root / "policy.lua").read_text()
runtime.execute(fixture)
runtime.execute((root / "main.lua").read_text())
runtime.execute('''
tick(.05); tick(3); check(.2,.2)
-- A native getter failure after dimming cannot leave stale opacity behind.
rejectGetters=true; tick(3.1)
check(1,1)
assert(callback()==true, "getter error should disable the candidate")
assert(getterCalls >= 2)
''')

runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.globals().policySource = (root / "policy.lua").read_text()
runtime.execute(fixture)
runtime.execute((root / "main.lua").read_text())
runtime.execute('''
tick(.05); tick(3); check(.2,.2)
hud.visible=false; tick(3.1) -- HUD switched/removed while dimmed
check(1,1)
assert(callback()==false, "HUD disappearance should wait for a new owner, not disable")
hud.visible=true; for _=1,20 do tick(4.2) end -- bounded next discovery pass
check(1,1)
assert(getterCalls >= 2)
''')

runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.globals().policySource = (root / "policy.lua").read_text()
runtime.execute(fixture)
runtime.execute((root / "main.lua").read_text())
runtime.execute('''
tick(.05); tick(3); check(.2,.2)
assert(deviceGetterCalls >= 2, "controller-owned device getter was not exercised")
press("Gamepad_FaceButton_Top"); tick(3.05); check(1,1)
releaseKey("Gamepad_FaceButton_Top")
tick(4.5); check(1,1)
tick(5.0); check(.6,.6)
tick(5.5); check(.2,.2)
-- Skill modifier affects only the two separate right-side roots.
skillHeld=true; skillExpected=1; tick(6); check(.2,.2)
skillHeld=false; tick(7); check(.2,.2)
skillExpected=.6; tick(7.5); check(.2,.2)
skillExpected=nil; tick(8); check(.2,.2)
-- Menu confirmation must not be mistaken for world interaction.
inputMode=1; menu.visibility=2; menuExpected=1; tick(8.1)
press("Gamepad_FaceButton_Top"); tick(8.2); check(.2,.2)
releaseKey("Gamepad_FaceButton_Top")
inputMode=0; menu.visibility=3; tick(8.3); check(.2,.2)
-- Current bindings are resolved again after UI exit, not hardcoded.
inputMode=1; tick(9)
keyMap["PC-Joystick-Interact"] = "Gamepad_FaceButton_Right"
inputMode=0; tick(9.1)
press("Gamepad_FaceButton_Top"); tick(9.2); check(.2,.2)
releaseKey("Gamepad_FaceButton_Top")
press("Gamepad_FaceButton_Right"); tick(9.3); check(1,1)
releaseKey("Gamepad_FaceButton_Right")
assert(not disabled, "candidate unexpectedly disabled")
''')

# End-to-end mock coverage: 6s injured hold, partial healing not refreshing it,
# no bright flash on full healing, and restart after exiting combat wounded.
runtime = LuaRuntime(unpack_returned_tuples=True)
runtime.globals().policySource = (root / "policy.lua").read_text()
runtime.execute(fixture)
runtime.execute((root / "main.lua").read_text())
runtime.execute('''
tick(.05); tick(3); check(.2,.2)
hp=90; tick(3.1); check(1,1)
hp=95; tick(7); check(.2,1) -- partial healing does not restart the 6s clock
tick(9.1); check(.2,1)
tick(9.6); check(.2,.6)
tick(10.1); check(.2,.2)
hp=100; tick(10.2); check(.2,.2) -- full healing does not brighten a dim HUD
hp=80; tick(11); check(1,1)
fighting=true; tick(11.1); check(1,1)
fighting=false; tick(12); check(1,1)
tick(18); check(.2,1)
tick(18.5); check(.2,.6)
tick(19); check(.2,.2)
assert(not disabled)
''')

print('PASS: 17 targets, finite injured hold, HP/combat, semantic Interact, skill hold/release, UI isolation, rebind, rollback and fail-safe.')
