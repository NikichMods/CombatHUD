import sys
from pathlib import Path

from lupa import LuaRuntime

root=Path(__file__).resolve().parents[1]/"Scripts"
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().policySource=(root/'policy.lua').read_text()
lua.execute('''
package.preload.policy=function() return assert(load(policySource))() end
now=0; fighting=false; calls=0; wrongPawn=false
local function object(address)
 return { IsValid=function() return true end, GetAddress=function() return address end,
 GetFullName=function() return "MockObject" end }
end
characterClass=object(10)
characterClass.GetFName=function() return {ToString=function() return "GenesisCharacter" end} end
player=object(20); player.GetClass=function() return characterClass end
global=object(30)
global.GetIsBattleState=function(self,who)
 assert(who==player,"A non-character object was passed to the native battle getter")
 calls=calls+1; return fighting
end
panels={object(40),object(41),object(42)}
for _,p in ipairs(panels) do p.SetRenderOpacity=function(self,a) self.alpha=a end end
hud=object(50)
hud.IsInViewport=function() return true end
hud.GetOwningPlayerPawn=function() if wrongPawn then return object(999) end return player end
hud.LeftBottom_Panel=panels[1]; hud.HUDSkillUMG_BP=panels[2]; hud.HUDActiveSkillUMG_BP=panels[3]
function FindAllOf() return {hud} end
function FindFirstOf() return global end
function StaticFindObject() return {IsValid=function() return true end,ForEachProperty=function() end} end
function LoopAsync(ms,fn) callback=fn end
function ExecuteInGameThread(fn) fn() end
package.preload.UEHelpers=function()
 return {GetGameplayStatics=function() return {GetTimeSeconds=function() return now end} end}
end
''')
lua.execute((root/'main.lua').read_text())
lua.execute('for i=1,65 do now=i*.05; callback() end; assert(calls>20); assert(math.abs(panels[1].alpha-.2)<1e-7)')
lua.execute('fighting=true; now=4; callback(); now=5; callback(); for _,p in ipairs(panels) do assert(p.alpha==1) end')
lua.execute('wrongPawn=true; now=5.1; callback(); for _,p in ipairs(panels) do assert(p.alpha==1) end')
print('PASS: adapter invokes battle getter with owning pawn; all three panels dim/reveal; wrong objects cannot reach getter.')
