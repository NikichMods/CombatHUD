import sys
from pathlib import Path

from lupa.lua54 import LuaRuntime

root=Path(__file__).resolve().parents[1]/"Scripts"
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute('assert(load(...))',(root/'main.lua').read_text())
policy=lua.execute((root/'policy.lua').read_text())
cfg=lua.table_from({'idleOpacity':0.20,'exitDelay':1.5,'fadeSeconds':1.0})
state=policy.new()
def step(t,b): return policy.step(state,t,b,cfg)
assert step(10,True)==(1.0,'combat')
assert step(11,False)==(1.0,'hold')
assert step(12.49,False)==(1.0,'hold')
a,m=step(13,False); assert abs(a-.6)<1e-8 and m=='fading'
assert step(13.5,False)==(.2,'idle')
assert step(14,True)==(.2,'revealing')
a,m=step(14.5,True); assert abs(a-.6)<1e-8 and m=='revealing'
assert step(15,True)==(1.0,'combat')
assert step(16,False)==(1.0,'hold')
a,m=step(18,False); assert abs(a-.6)<1e-8
# Reverse midway without a brightness jump, then finish revealing in one second.
assert step(18,True)==(a,'revealing')
mid,m=step(18.5,True); assert abs(mid-.8)<1e-8
assert step(19,True)==(1.0,'combat')
assert step(0,False)==(1.0,'hold')
assert step(1,None)==(1.0,'unknown')
assert step(2,False)==(1.0,'hold')
assert step(2,False)==(1.0,'hold')

# HP-aware policy: two independent clocks, immediate damage reveal, stable
# partial HP on first observation, full heal, and conservative re-baselining.
health=policy.newHealth()
def h(t,b,hp=100,maxhp=100): return policy.stepHealth(health,t,b,hp,maxhp,cfg)
assert h(0,False)==(1.0,1.0,'hold','hold',False)
assert h(1.5,False)==(1.0,1.0,'hold','hold',False)
o,v,*_=h(2,False); assert abs(o-.6)<1e-8 and abs(v-.6)<1e-8
assert h(2.5,False)[:2]==(.2,.2)
assert h(3,False,70)[:2]==(1.0,1.0)  # damage immediately cancels both fades
assert h(3,False,70)[-1] is False    # no repeated damage event
assert h(4.5,False,70)[:2]==(1.0,1.0)
o,v,*_=h(5,False,70); assert abs(o-.6)<1e-8 and v==1.0
assert h(5.5,False,70)[:2]==(.2,1.0)
assert h(6,False,70)[:2]==(.2,1.0)
assert h(7,False,100)[:2]==(.2,1.0)   # healing doesn't reset ordinary timer
assert h(8.5,False)[:2]==(.2,1.0)
o,v,*_=h(9,False); assert o==.2 and abs(v-.6)<1e-8
assert h(9.5,False)[:2]==(.2,.2)
assert h(10,False,90)[:2]==(1.0,1.0)
assert h(10.1,False,80)[:2]==(1.0,1.0)  # repeated loss restarts hold
assert h(12.1,False,80)[1]==1.0 and abs(h(12.1,False,80)[0]-.6)<1e-8
assert h(13,True,80)[1]==1.0

health=policy.newHealth()
assert h(0,False,40)[:2]==(1.0,1.0)   # no fake damage on initial partial HP
assert h(3,False,40)[:2]==(.2,1.0)
assert h(4,False,20,200)[:2]==(1.0,1.0)  # max change: fresh baseline
assert h(7,False,20,200)[:2]==(.2,1.0)
assert h(0,False,20,200)[:2]==(1.0,1.0)  # game time moved backwards
assert h(1,False,float('nan'),200)[:2]==(1.0,1.0)
assert h(2,False,20,200)[:2]==(1.0,1.0)
assert h(3,False,300,200)[:2]==(1.0,1.0)
assert h(4,None,10,200)[:2]==(1.0,1.0)
print('PASS: base policy, immediate damage, independent HP/item timer, partial load, heal, travel, pause, invalid getters.')
