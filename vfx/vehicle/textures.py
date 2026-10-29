"""Reproducible original tyre smoke + road grit, white/alpha. numpy + Pillow."""
from pathlib import Path
import sys
import os
import numpy as np
sys.path.insert(0,str(Path(os.environ.get('ROBLOX_VFX_SKILL',Path.home()/'.codex/skills/roblox-vfx'))/'scripts'))
import vfxtex as vt
vt.OUTPUT_DIR=str(Path(__file__).parent/'out')
def smoke(size):
    x,y=vt.tex_coords(size)
    noise=vt.tex_noise(size,scale=5,octaves=5,seed=718)
    shape=np.zeros_like(x)
    for cx,cy,r in [(-.28,-.03,.48),(.2,.05,.5),(-.05,.3,.38),(.08,-.3,.39)]:
        d=np.sqrt((x-cx)**2+(y-cy)**2)
        shape=np.maximum(shape,np.clip((r-d)/.17,0,1))
    alpha=shape*np.clip((noise-.17)*1.7,0,1)
    value=.58+.42*noise
    return alpha,value
def grit(size):
    x,y=vt.tex_coords(size)
    alpha=np.zeros_like(x)
    for cx,cy,r in [(-.25,.2,.21),(.28,-.13,.13),(-.12,-.3,.1)]:
        blob=vt.tex_blob(x,y,radius=r,lumps=5,roughness=.4,seed=int((cx+1)*100),centre=(cx,cy))
        alpha=np.maximum(alpha,np.clip(blob*100+.5,0,1))
    return np.clip(alpha,0,1)
print(vt.draw_texture('TyreSmoke',smoke,size=512))
print(vt.draw_texture('RoadGrit',grit,size=256))
