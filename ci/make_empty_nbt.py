# Minimális 3x3x3-as, levegőből álló struktúrasablon (1.21.1, DataVersion 3955) a GameTesthez.
import gzip, struct, sys
def s(x): b=x.encode(); return struct.pack('>H',len(b))+b
def named(t,n,p): return bytes([t])+s(n)+p
def i(v): return struct.pack('>i',v)
def ilist(vals): return bytes([3])+i(len(vals))+b''.join(i(v) for v in vals)
def comp(items): return b''.join(items)+b'\x00'
air = comp([named(8,'Name',s('minecraft:air'))])
blocks=[]
for x in range(3):
  for y in range(3):
    for z in range(3):
      blocks.append(comp([named(9,'pos',ilist([x,y,z])), named(3,'state',i(0))]))
root = named(10,'',comp([
  named(3,'DataVersion',i(3955)),
  named(9,'size',ilist([3,3,3])),
  named(9,'palette',bytes([10])+i(1)+air),
  named(9,'blocks',bytes([10])+i(len(blocks))+b''.join(blocks)),
  named(9,'entities',bytes([0])+i(0)),
]))
open(sys.argv[1],'wb').write(gzip.compress(root))
