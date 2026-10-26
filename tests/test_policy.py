import sys
from pathlib import Path

from lupa import LuaRuntime

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
print('PASS: syntax; 20% idle; 1-second dim/reveal; exit delay; mid-fade reversal; travel; unknown state; pause.')
