"""Offline safety checks for the research controller; not engine rendering acceptance."""
from pathlib import Path
from lupa import LuaRuntime

SOURCE=Path(__file__).with_name('main.lua').read_text(encoding='utf-8-sig')
FIXTURE=r'''
logs={}; queue={}; keys={}; nextAddress=0; clock=100
os.time=function() return clock end
function print(s) logs[#logs+1]=s end
Key={F8='F8',F9='F9',F10='F10'}; ModifierKey={CONTROL='CONTROL'}
function RegisterKeyBind(key,mods,fn) assert(mods[1]=='CONTROL'); keys[key]=fn end
function LoopAsync(ms,fn) assert(ms==50); loop=fn end
function ExecuteInGameThread(fn) queue[#queue+1]=fn end
function frame() loop(); local q=queue; queue={}; for _,fn in ipairs(q) do fn() end end
function classname(n,super)
 return {IsValid=function() return true end,GetFName=function() return {ToString=function() return n end} end,GetSuperStruct=function() return super end}
end
local widgetClass=classname('Widget',nil)
local panelClass=classname('PanelWidget',widgetClass)
objects={}
function object(n,cls,parent)
 nextAddress=nextAddress+1
 local super=(cls=='CanvasPanel' or cls=='HorizontalBox') and panelClass or widgetClass
 local c=classname(cls,super)
 local o={n=n,cls=c,parent=parent,alpha=1,visibility=4,children={},address=nextAddress,valid=true,writes=0}
 function o:IsValid() return self.valid end
 function o:GetAddress() return self.address end
 function o:GetFName() return {ToString=function() return self.n end} end
 function o:GetFullName() return self.n end
 function o:GetClass() return self.cls end
 function o:GetParent() return self.parent end
 function o:GetChildrenCount() return #self.children end
 function o:GetChildAt(i) return self.children[i+1] end
 function o:GetRenderOpacity() return self.alpha end
 function o:GetVisibility() return self.visibility end
 function o:SetRenderOpacity(x) self.alpha=x; self.writes=self.writes+1 end
 function o:SetVisibility() error('Unexpected Visibility write') end
 if parent then parent.children[#parent.children+1]=o end
 objects[n]=o
 return o
end
hud=object('HUDMainUMG_BP','HUDMainUMG_BP_C',nil)
pawn=object('hilda','GenesisCharacter',nil)
function hud:IsInViewport() return true end
function hud:GetOwningPlayerPawn() return pawn end
function FindAllOf(n) assert(n=='HUDMainUMG_BP_C'); return {hud} end
local root=object('hud-root','CanvasPanel',nil)
local hp=object('HUD_Panel','CanvasPanel',root)
local left=object('LeftBottom_Panel','CanvasPanel',hp); hud.LeftBottom_Panel=left
local status=object('HUDStatusBarUMG_BP','HUDStatusBarUMG_BP_C',left); hud.HUDStatusBarUMG_BP=status
local sr=object('status-root','CanvasPanel',nil)
local sm=object('Main_Panel','CanvasPanel',sr)
for _,n in ipairs({'HPBar','HPDamageBar','HPArrow_Image','WarningBar','HPFrameLine0_Img','HPFrameLine1_Img','HPFrameLine2_Img','HPFrameLine3_Img','APBar','ExpBar','UnUsePoint_Image','DamageTipList_Panel'}) do
 status[n]=object(n,'Image',sm)
end
local items=object('HUDUseItemUMG_BP','HUDUseItemUMG_BP_C',left); hud.HUDUseItemUMG_BP=items
local ir=object('CanvasPanel_0','CanvasPanel',nil)
local quick=object('QuickItem_Panel','CanvasPanel',ir)
local crystals=object('CrystalList_Panel','HorizontalBox',ir)
items.HUDCrystalUMG_Pad_BP=object('HUDCrystalUMG_Pad_BP','HUDCrystalUMG_Pad_BP_C',ir)
for i=0,3 do items['KBCrystalSlot'..i]=object('KBCrystalSlot'..i,'HUDCrystalSlotUMG_BP_C',crystals) end
for i=0,2 do
 local slot=object('QuickItem'..i,'HUDItemSlotUMG_BP_C',quick); items['QuickItem'..i]=slot; slot.SlotIndex=i
 local slotRoot=object('slot-root'..i,'CanvasPanel',nil)
 local main=object('MainPanel','CanvasPanel',slotRoot)
 for _,n in ipairs({'Bg_Image','Icon_Image','ValueBg_Image','Key_Image','Value_Text'}) do
  slot[n]=object(n,n=='Value_Text' and 'TextBlock' or 'Image',main)
 end
end
hud.HUDSkillUMG_BP=object('HUDSkillUMG_BP','HUDSkillUMG_BP_C',hp)
hud.HUDActiveSkillUMG_BP=object('HUDActiveSkillUMG_BP','HUDActiveSkillUMG_BP_C',hp)
'''

def runtime():
    lua=LuaRuntime()
    lua.execute(FIXTURE)
    lua.execute(SOURCE)
    return lua

lua=runtime()
lua.execute('''
frame(); assert(table.concat(logs):find('event=READY',1,true))
for _,o in pairs(objects) do assert(o.writes==0) end
keys.F8(); frame()
assert(objects.QuickItem_Panel.alpha==1 and objects.HPBar.alpha==1)
assert(objects.APBar.alpha==0.2 and objects.CrystalList_Panel.alpha==0.2)
assert(objects.HUDSkillUMG_BP.alpha==0.2)
assert(objects.LeftBottom_Panel.writes==0 and objects.HUDUseItemUMG_BP.writes==0)
local writes=objects.APBar.writes; frame(); assert(objects.APBar.writes==writes)
objects.HUD_Panel.alpha=0; objects.HUD_Panel.visibility=2; frame()
assert(objects.HUD_Panel.alpha==0 and objects.HUD_Panel.visibility==2)
objects.HUD_Panel.alpha=1; objects.HUD_Panel.visibility=4
keys.F9(); frame(); assert(objects.APBar.alpha==1 and objects.CrystalList_Panel.alpha==1)
keys.F8(); frame(); keys.F10(); frame()
assert(table.concat(logs):find('cleanup=true',1,true))
assert(loop()==true)
for _,o in pairs(objects) do assert(o.alpha==1) end
keys.F8(); frame(); assert(objects.APBar.alpha==1)
''')
lua=runtime()
lua.execute('''
frame(); keys.F8(); frame()
objects.APBar.alpha=0.4; frame()
assert(table.concat(logs):find('event=NATIVE_WRITE',1,true))
assert(table.concat(logs):find('cleanup=false',1,true))
assert(objects.APBar.alpha==0.4) -- Do not overwrite a newer native value during rollback.
assert(objects.ExpBar.alpha==1 and objects.CrystalList_Panel.alpha==1)
assert(loop()==true)
''')
lua=runtime()
lua.execute('''
pawn.cls=classname('DefaultPawn',nil); frame()
assert(table.concat(logs):find('event=WAIT_OWNER',1,true))
assert(not table.concat(logs):find('event=REJECT',1,true))
for _,o in pairs(objects) do assert(o.writes==0) end
''')
lua=LuaRuntime()
lua.execute(FIXTURE)
lua.execute("hud.HUDUseItemUMG_BP.QuickItem0.Bg_Image.n='BG_Image'")
lua.execute(SOURCE)
lua.execute("frame(); assert(table.concat(logs):find('event=READY',1,true)); keys.F8(); frame(); keys.F10(); frame(); assert(table.concat(logs):find('cleanup=true',1,true))")
print('PASS: split/full, no per-tick writes, native parent hiding, rollback, native conflict containment, startup owner wait, FName display-spelling variation')
