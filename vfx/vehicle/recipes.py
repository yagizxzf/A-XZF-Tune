"""Generate original vehicle ParticleEmitter recipes for the skill's Build module."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parent
def recipes(smoke,grit,dust=False):
    color=[.56,.48,.37] if dust else [.63,.65,.66]
    def emitter(name,texture,count,delay,life,speed,size,trans,color,accel):
        return {"op":"create","className":"ParticleEmitter","name":name,"parent":"$contact","properties":{
            "Texture":texture,"Enabled":False,"Rate":0,"Lifetime":life,"Speed":speed,"Drag":5,
            "SpreadAngle":[65,65],"EmissionDirection":"Top","Acceleration":accel,
            "Rotation":[0,360],"RotSpeed":[-40,40],"Color":color,"LightEmission":0,"LightInfluence":1,
            "Size":[{"time":a,"value":b} for a,b in size],"Transparency":[{"time":a,"value":b} for a,b in trans]},
            "attributes":{"EmitCount":count,"EmitDelay":delay}}
    return [
        {"op":"create","className":"Attachment","id":"contact","name":"Contact","parent":"$part"},
        emitter("SmokeBody",smoke,4,0,[.5,.8],[1.5,4],[(0,.7),(.3,2.2),(1,3.5)],[(0,.35),(.4,.6),(1,1)],color,[0,2,0]),
        emitter("SecondaryBillow",smoke,2,.06,[.7,1.05],[1,2.5],[(0,.9),(.4,2.8),(1,4)],[(0,.65),(.5,.8),(1,1)],[.48,.5,.52] if not dust else [.55,.46,.35],[0,1.5,0]),
        emitter("RoadGrit",grit,6,0,[.2,.4],[3,7],[(0,.3),(1,.04)],[(0,.15),(.7,.55),(1,1)],[.14,.13,.12],[0,-9,0]),
    ]
def main():
    import argparse
    p=argparse.ArgumentParser();p.add_argument('--smoke',required=True);p.add_argument('--grit',required=True);p.add_argument('--preview',action='store_true');a=p.parse_args()
    data={"AXZFTyreSmoke":recipes(a.smoke,a.grit),"AXZFSurfaceDust":recipes(a.smoke,a.grit,True)}
    path=ROOT/('preview-recipes.json' if a.preview else 'recipes.json')
    path.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8');print(path)
if __name__=='__main__':main()
