"""A-XZF cockpit. Original generated physical controls: art/v4/provenance.json."""
from pathlib import Path
import html
import math
ROOT=Path(__file__).resolve().parent
CSS=''' .dial{background:rgba(13,20,25,.94);border:2px solid #3a4b55;border-radius:50%} *{box-sizing:border-box}html,body{margin:0;background:#161d22;font-family:Arial,sans-serif;color:#f5f5f0}#stage{position:relative;width:1920px;height:1080px;overflow:hidden;background:linear-gradient(160deg,#364d58,#161d22 60%)}.abs{position:absolute}.fill{inset:0}.world{position:absolute;inset:0;background:linear-gradient(170deg,transparent 58%,#414648 58%,#20272b 100%)}.road{position:absolute;left:51%;top:62%;height:450px;width:8px;background:#c6c8bd;transform:rotate(19deg)}.cap{position:absolute;left:54px;top:48px;font-size:22px;color:#b3c2c8}.panel{background:rgba(13,20,25,.94);border:1px solid #3a4b55;border-radius:8px}.text{position:absolute;display:block;white-space:nowrap;line-height:1.2}.button{background:#202e36;border:1px solid #52616a;border-radius:6px}.amber{color:#ffbc63}.hint{color:#b6c5cd}.bar{background:#33434d;border-radius:2px}.hid{opacity:0}.grp{pointer-events:none}.grp [data-btn]{pointer-events:auto;cursor:pointer}.physical{background:transparent;border:1px solid transparent;border-radius:12px}.physical:active{background:rgba(255,188,99,.12);border-color:#ffbc63}.physical:active [data-n$=Art]{filter:brightness(1.15)}.utility{background:rgba(13,20,25,.78);border:1px solid #52616a;border-radius:12px}.review{padding:32px;max-width:1200px;margin:auto}.review a{color:#ffbc63}'''
def box(name,x,y,w,h,cls='panel',inner='',btn=False):
    return f"<div class='abs {cls}' data-n='{name}' {'data-btn=1' if btn else ''} style='left:{x}px;top:{y}px;width:{w}px;height:{h}px'>{inner}</div>"
def text(name,label,x,y,w,h,size=24,color='#f5f5f0',weight=400):
    return f"<span class='text' data-n='{name}' style='left:{x}px;top:{y}px;width:{w}px;height:{h}px;font-size:{size}px;font-weight:{weight};color:{color}'>{html.escape(label)}</span>"
def group(name,inner,anchor): return f"<div class='abs fill grp' data-g='{name}' data-a='{anchor}'>{inner}</div>"
def button(name,label,x,y,w=130,h=58):
    return box(name,x,y,w,h,'button',text(name+'Label',label,12,17,w-20,28,20,weight=700),True)

def prop(name,col,row,x,y,size):
    return f"<div class='abs' data-n='{name}' style='left:{x}px;top:{y}px;width:{size}px;height:{size}px;background-image:url(art/v4/control-atlas.png);background-size:200% 200%;background-position:{col*100}% {row*100}%'></div>"

def physical_button(name,col,row,x,y,w,h,size):
    art=prop(name+'Art',col,row,(w-size)/2,(h-size)/2,size)
    fallback=text(name+'Fallback',{'Throttle':'GAZ','Brake':'FREN','Handbrake':'EL FRENİ'}[name],8,h/2-16,w-16,32,24,weight=700).replace("class='text'","class='text hid'")
    return box(name,x,y,w,h,'physical',art+fallback,True)


def page(name,body):
    (ROOT/(name+'.html')).write_text(f"<!doctype html><meta charset='utf-8'><title>A-XZF Tune / {name}</title><style>{CSS}</style><div id='stage'><div class='world'><div class='road'></div></div><div class='cap'>A-XZF-TUNE · COCKPIT PREVIEW / SAMPLE VALUES</div>{body}</div><script>window.checkOverflow=()=>({{overflow:[...document.querySelectorAll('span[data-n]')].filter(e=>e.scrollWidth>e.clientWidth+1||e.scrollHeight>e.clientHeight+1).map(e=>e.dataset.n),broken:[...document.images].filter(e=>!e.complete||!e.naturalWidth).map(e=>e.src)}});if(!location.search.includes('raw')){{document.getElementById('stage').style.transformOrigin='top left';document.getElementById('stage').style.transform='scale('+Math.min(innerWidth/1920,innerHeight/1080)+')';}}</script>",encoding='utf-8')
def dashboard(park=False,mobile=False):
    x,y=(790,695) if mobile else (1510,695)
    inner=box('DialRing',0,0,330,330,'dial',inner='')
    for i in range(41):
        a=math.radians(135+i*6.75)
        bx,by=165+139*math.cos(a),165+139*math.sin(a)
        color='#ff786a' if i>35 else '#ffbc63' if i<28 else '#435762'
        inner+=f"<div class='abs' data-n='RPM{i}' style='left:{bx-2}px;top:{by-7}px;width:4px;height:14px;background:{color};transform:rotate({i*6.75+45}deg)'></div>"
    for i in range(9):
        a=math.radians(135+i*33.75)
        bx,by=165+112*math.cos(a),165+112*math.sin(a)
        inner+=text('Tick'+str(i),str(i),bx-10,by-10,22,25,17,'#bdcbd2',700)
    inner+=text('Brand','A-XZF-TUNE',97,85,150,24,17,'#a7bac4',700)
    inner+=text('Speed','084',102,120,148,74,62,weight=700)+text('Unit','STUD/S',132,196,110,23,16,'#a7bac4')
    inner+=text('Gear','P' if park else '3',151,225,45,40,31,'#ffbc63',700)
    inner+=text('RPM','4 850 RPM',113,273,150,23,18,'#b6c5cd')
    inner+=text('ParkStatus','PARK ON' if park else 'DRIVE',35,338,130,25,18,'#ffbc63' if park else '#b6c5cd',700)
    inner+=text('HandbrakeStatus','HB ON' if park else 'HB OFF',185,338,130,25,18,'#ffbc63' if park else '#b6c5cd',700)
    return group('DashboardMobile' if mobile else 'Dashboard',box('Cockpit',x,y,330,370,'',inner=inner),'B' if mobile else 'BR')
def controls():
    inner=text('ControlsTitle','DRIVING CONTROLS',20,16,230,24,18,'#ffbc63',700)
    for i,(key,label) in enumerate([('W / S','Drive / reverse'),('A / D','Steer'),('B','Brake'),('SPACE','Toggle handbrake'),('P','Park / drive'),('E','Exit vehicle'),('H','Hide controls')]):
        inner+=text('Key'+str(i),key,20,56+i*32,85,27,17,'#f5f5f0',700)+text('Control'+str(i),label,115,56+i*32,190,27,18,'#b6c5cd')
    return group('Controls',box('ControlPanel',50,708,335,302,inner=inner),'BL')
def touch(active=False):
    steering=''
    for i,name in enumerate(['SteerLeft','SteerRight']):
        art=f"<div class='abs' data-n='{name}Art' style='left:0;top:0;width:145px;height:200px;background-image:url(art/v4/steering-buttons.png);background-size:200% auto;background-position:{i*100}% 50%'></div>"
        fallback=text(name+'Fallback','SOL' if i==0 else 'SAĞ',15,84,115,32,24,weight=700).replace("class='text'","class='text hid'")
        steering+=box(name,50+i*165,810,145,200,'physical',art+fallback,True)
    pedals=physical_button('Brake',1,0,1490,785,190,220,220)
    pedals+=physical_button('Throttle',0,0,1700,720,150,285,285)
    hand=physical_button('Handbrake',0,1,1670,490,180,180,180)
    utility=button('Park','P',50,150,90,78)+button('Reverse','R',160,150,90,78)
    utility+=button('ToggleControls','TUŞ',50,244,90,78)+button('Exit','ÇIK',160,244,90,78)
    return group('TouchLeft',steering,'BL')+group('TouchPedals',pedals,'BR')+group('TouchHandbrake',hand,'BR')+group('TouchUtility',utility,'TL')

toggle=group('Toggle',button('ShowControls','H  CONTROLS',50,628,185),'BL')
status=group('Recovery',box('RecoveryPanel',710,120,500,68,inner=text('RecoveryText','AUTO RECOVERY · CHECKING CLEARANCE',20,22,460,27,20,'#ffbc63',700)),'T')
page('hud',dashboard()+controls()+toggle)
page('hud_phone',dashboard(mobile=True)+touch())
page('states',dashboard(True)+controls()+toggle+status)
page('templates',touch()+status)
page('mobile_states',dashboard(True,mobile=True)+touch(True))
(ROOT/'style.html').write_text(f"<meta charset='utf-8'><style>{CSS}</style><div class='review'><h1>A-XZF circular cockpit</h1><p>Original circular instrument inspired by A-Chassis: speed in the center, RPM around the dial, amber gear and parking state. Original physical pedal, handbrake and steering artwork; mobile racing references inform grouping only.</p><p>Hidden controls keep the driving gauges visible. Mobile buttons remain usable when the keyboard help is hidden.</p><p>Sample speed is in studs/second, not a claimed real-world unit conversion.</p><p><a href='hud.html'>Desktop</a> · <a href='hud_phone.html'>Mobile</a> · <a href='states.html'>Parking / recovery states</a></p><div style='height:60px;background:#0d1419;border:1px solid #3a4b55;padding:18px;color:#ffbc63'>INK #0D1419 · AMBER #FFBC63 · TEXT #F5F5F0</div></div>",encoding='utf-8')
(ROOT/'index.html').write_text("<meta charset='utf-8'><title>A-XZF cockpit review</title><style>body{background:#111b22;color:white;font:20px Arial;padding:40px}a{color:#ffbc63;display:block;margin:20px}</style><h1>A-XZF driving UI</h1><a href='style.html'>Style and behavior</a><a href='hud.html'>Desktop cockpit</a><a href='hud_phone.html'>Mobile controls</a><a href='states.html'>Parking / automatic recovery</a>",encoding='utf-8')
print('Built cockpit review pages')
