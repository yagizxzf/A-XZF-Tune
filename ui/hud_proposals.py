"""Generate the design review from layer-based cockpit layouts."""

from dataclasses import dataclass
from html import escape
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "rbx/out/hud-review"


@dataclass(frozen=True)
class Theme:
    key: str
    name: str
    note: str
    face: str
    edge: str
    bezel: str
    accent: str
    quiet: str
    ink: str
    hint: str
    button: str
    button_edge: str
    lit_button: str
    button_ink: str
    radius: int
    digits: str
    ticks: int

    def properties(self):
        fields = ("face", "edge", "bezel", "accent", "quiet", "ink", "hint",
                  "button", "button_edge", "lit_button", "button_ink", "radius", "digits")
        return ";".join(f"--{key.replace('_', '-')}:{getattr(self, key)}" for key in fields)


THEMES = (
    Theme("a", "A · Turkuaz Cam", "İnce cam çerçeve, büyük dijital hız ve sade kumandalar.",
          "rgba(5,28,35,.91)", "#72c4cc", "#244953", "#8ef7e6", "#33555c",
          "#f1fffd", "#b9d3d6", "rgba(7,37,45,.83)", "#71a6af", "#186067", "#eafffc",
          11, "Bahnschrift,Arial,sans-serif", 25),
    Theme("b", "B · Emaye", "Krem kadran, kırmızı devir çizgileri ve koyu vites penceresi.",
          "#f1e4c9", "#3a302b", "#c3af8c", "#aa321f", "#bcaa8b",
          "#26211f", "#5e493d", "#f1e4c9", "#58504b", "#e1af88", "#302521",
          23, "Georgia,serif", 21),
    Theme("c", "C · Gece Pisti", "Koyu mor zemin, parlak yarış şeritleri ve köşeli düğmeler.",
          "rgba(26,14,42,.95)", "#bd71ff", "#683a90", "#f5b0ff", "#51336b",
          "#fff7ff", "#e0c7f1", "rgba(37,17,57,.91)", "#a87ce5", "#5d2985", "#fff6ff",
          5, "Consolas,monospace", 14),
)

PHONE = (844, 390)
DESKTOP = (1056, 594)
PORTRAIT = (390, 750)
STYLE = """
*{box-sizing:border-box}
.stage{position:relative;isolation:isolate;overflow:hidden;background:#536b82 url(scene.jpg) center/cover no-repeat}
.stage .node{position:absolute}
.stage .group{position:absolute;inset:0;pointer-events:none}
.stage [data-btn]{pointer-events:auto;cursor:pointer;touch-action:none}
.stage .dial{border:2px solid var(--edge);border-radius:50%;background:var(--face)}
.stage .bezel{border:1px solid var(--bezel);border-radius:50%}
.stage .label{display:flex;align-items:center;line-height:1;white-space:nowrap;color:var(--ink)}
.stage .label::after{content:attr(data-t);color:inherit}
.stage .center{justify-content:center}
.stage .muted{color:var(--hint)}
.stage .digits{font-family:var(--digits);font-variant-numeric:tabular-nums;letter-spacing:-.04em}
.stage .tick{background:var(--quiet);border-radius:1px;transition:background-color 120ms}
.stage .tick.on{background:var(--accent)}
.stage .tick.limit.on{background:#ec4d52}
.stage .badge{background:var(--button);border:1px solid var(--button-edge);border-radius:6px}
.stage .accent{color:var(--accent)}
.stage .signal{color:var(--accent);font-weight:700}
.stage .face{border:1px solid var(--button-edge);background:var(--button);
 border-radius:calc(var(--radius) * 1px);transition:transform 110ms,background-color 110ms}
.stage .utility{border-radius:calc(var(--radius) * .58px)}
.stage .button-label{color:var(--button-ink)}
.stage [data-btn]:active .face,.stage [data-btn].engaged .face{background:var(--lit-button)}
.stage [data-btn]:active .face{transform:scale(.92)}
.stage [data-btn]:active [data-n$=Art]{transform:scale(.94)}
.stage [data-n$=Art]{transition:transform 110ms}
.stage .panel{border:1px solid var(--button-edge);border-radius:12px;background:var(--button)}
.stage .gone{opacity:0;pointer-events:none}
.stage .help{transition:opacity 170ms}
.stage .help .panel{transition:transform 170ms}
.stage .help.gone .panel{transform:translateY(8px)}
.stage .rise{animation:rise 290ms cubic-bezier(.2,.75,.3,1) both}
@keyframes rise{from{transform:translateY(16px);opacity:.4}to{transform:translateY(0);opacity:1}}
@media(prefers-reduced-motion:reduce){.stage *{animation:none!important;transition:none!important}}
.theme-b .bezel{border-width:3px}
.theme-b .badge{background:#3b312d;border-color:#69574b}
.theme-b .badge-label{color:#fff1d6}
.theme-b .signal{color:#8b231c}
.theme-c .dial{border-width:3px}
.theme-c .bezel{border-style:dashed}
.theme-c .badge{border-radius:3px}
"""

BODY = """
*{box-sizing:border-box}
html{color-scheme:dark}
body{margin:0;background:#111820;color:#eef4f7;font:15px Arial,sans-serif}
main{margin:auto;max-width:1330px;padding:30px 24px}
h1{margin:0 0 10px;font-size:30px;font-weight:700}
h2{margin:24px 0 4px;font-size:20px}
p{margin:0 0 14px;color:#b9c6cd;line-height:1.5}
.pickers,.options{display:flex;gap:8px;flex-wrap:wrap;margin:16px 0}
button{border:1px solid #566573;border-radius:7px;background:#1b2933;color:#f7fafb;
 cursor:pointer;padding:9px 12px;font:600 14px Arial,sans-serif}
button[aria-pressed=true]{border-color:#9be6dc;background:#213b41}
.devices{display:grid;grid-template-columns:1fr 1fr;gap:16px}
.devices figure{margin:0;min-width:0}
figcaption{margin:0 0 6px;font-weight:700;color:#e1edf3}
iframe{display:block;width:100%;border:1px solid #445461;border-radius:12px;background:#536b82}
.review-only{color:#a6b7c2;margin-top:16px}
@media(max-width:820px){.devices{grid-template-columns:1fr}main{padding:22px 14px}}
@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto!important}}
"""


def box(name, x, y, w, h, cls="", children="", extra=""):
    return (f"<div class='node {cls}' data-n='{name}' {extra} "
            f"style='left:{x}px;top:{y}px;width:{w}px;height:{h}px'>{children}</div>")


def text(name, value, x, y, w, h, size, cls="", weight=700, center=True):
    attrs = f"data-n='{name}' data-t='{escape(value, quote=True)}' aria-label='{escape(value, quote=True)}'"
    label = (f"<span class='node label {'center' if center else ''} {cls}' {attrs} "
             f"style='inset:0;font-size:{size}px;font-weight:{weight}'></span>")
    slot = "text-align:center" if center else "text-align:left"
    return (f"<div class='node' data-n='{name}Slot' style='{slot};left:{x}px;top:{y}px;"
            f"width:{w}px;height:{h}px'>{label}</div>")


def group(name, children, cls=""):
    return f"<div class='group {cls}' data-g='{name}'>{children}</div>"


def dial(theme, width, height, mobile):
    r = 138 if mobile else 210
    left = width / 2 - r if mobile else width - r
    top = height - r
    layers = box("DialRing", 0, 0, 2 * r, 2 * r, "dial")
    inset = 6 if theme.key == "b" else 5
    layers += box("Bezel", inset, inset, 2 * (r - inset), 2 * (r - inset), "bezel")
    for i in range(theme.ticks):
        angle = math.radians(184 + (172 if mobile else 82) * i / (theme.ticks - 1))
        major = i % (4 if theme.key == "a" else 3) == 0
        mark_width = 5 if theme.key == "c" else 2 if theme.key == "b" else 3
        mark_length = (13 if major else 7) + (0 if mobile else 2)
        radial = r - (14 if theme.key == "a" else 17)
        x = r + radial * math.cos(angle) - mark_width / 2
        y = r + radial * math.sin(angle) - mark_length / 2
        cls = "tick on" if i < theme.ticks * .62 else "tick"
        if i >= theme.ticks * .87:
            cls += " limit"
        layers += (f"<div class='node {cls}' data-n='RPM{i}' style='left:{x:.2f}px;top:{y:.2f}px;"
                   f"width:{mark_width}px;height:{mark_length}px;"
                   f"transform:rotate({math.degrees(angle) + 90:.2f}deg)'></div>")

    if mobile:
        speed, meters, gear, rpm, status = {
            "a": ((83, 31, 110, 53, 48), (84, 82, 108, 15, 11), (65, 102, 48, 25),
                  (120, 102, 118, 25), (94, 20, 88, 12)),
            "b": ((42, 55, 100, 54, 46), (44, 107, 94, 16, 10), (155, 59, 66, 32),
                  (137, 94, 106, 26), (138, 42, 101, 12)),
            "c": ((42, 58, 96, 51, 43), (48, 107, 82, 15, 10), (150, 60, 64, 29),
                  (141, 94, 105, 25), (137, 43, 110, 12)),
        }[theme.key]
    else:
        speed, meters, gear, rpm, status = {
            "a": ((84, 53, 104, 64, 62), (84, 115, 104, 19, 13), (50, 152, 58, 33),
                  (109, 152, 91, 33), (115, 38, 86, 14)),
            "b": ((78, 57, 125, 78, 66), (90, 129, 96, 18, 12), (50, 158, 58, 34),
                  (108, 158, 95, 34), (116, 46, 88, 13)),
            "c": ((75, 60, 126, 76, 59), (90, 128, 96, 18, 12), (49, 157, 59, 35),
                  (108, 157, 97, 35), (112, 48, 91, 13)),
        }[theme.key]
    gx, gy, gw, gh = gear
    rx, ry, rw, rh = rpm
    sx, sy, sw, sh = status
    layers += text("Speed", "84", *speed, "digits")
    layers += text("Unit", "stud/sn", *meters, "muted")
    layers += box("GearFace", gx, gy, gw, gh, "badge")
    layers += text("Gear", "3", gx + gw - 23, gy, 18, gh, 18 if mobile else 21, "badge-label digits")
    layers += text("GearCaption", "VİTES", gx + 4, gy, gw - 25, gh, 8 if mobile else 9, "badge-label")
    layers += text("RPMValue", "4.850", rx, ry, rw * .54, rh, 14 if mobile else 16, "digits")
    layers += text("RPMCaption", "dev/dk", rx + rw * .54, ry, rw * .46, rh, 9 if mobile else 10, "muted")
    layers += text("ParkStatus", "PARKTA", sx, sy, sw * .48, sh, 8 if mobile else 9, "signal gone")
    layers += text("HandbrakeStatus", "EL FRENİ", sx + sw * .49, sy, sw * .51, sh, 8 if mobile else 9, "signal gone")
    return group("DashboardMobile" if mobile else "Dashboard",
                 box("Cockpit", left, top, 2 * r, 2 * r, "rise", layers))


def touch_button(name, label, x, y, w, h, art=None):
    compact = "utility" if art is None else ""
    inset_x, inset_y = (4, 9) if art is None else (3, 3)
    face = box(name + "Face", inset_x, inset_y, w - 2 * inset_x, h - 2 * inset_y, "face " + compact)
    if art is None:
        face += text(name + "Label", label, 2, 0, w - 4, h, 11, "button-label")
    else:
        col, row, art_w, art_h = art
        if row is None:
            background = f"url(../../../art/v4/steering-buttons.png) {col * 100}% 50% / 200% auto"
        else:
            background = f"url(../../../art/v4/control-atlas.png) {col * 100}% {row * 100}% / 200% 200%"
        face += (f"<div class='node' data-n='{name}Art' style='left:{(w-art_w)/2}px;top:{(h-art_h)/2}px;"
                 f"width:{art_w}px;height:{art_h}px;background:{background}'></div>")
        face += text(name + "Fallback", label, 3, 0, w - 6, h, 10, "button-label gone")
    return box(name, x, y, w, h, children=face, extra=f"data-btn='1' aria-label='{escape(label)}'")


def touch(width, height):
    lift = 146 if width < 564 else 0
    bottom = height - 12 - lift
    steering = touch_button("SteerLeft", "Sol", 12, bottom - 58, 56, 58, (0, None, 48, 66))
    steering += touch_button("SteerRight", "Sağ", 74, bottom - 58, 56, 58, (1, None, 48, 66))
    pedals = touch_button("Brake", "Fren", width - 144, bottom - 64, 64, 64, (1, 0, 50, 50))
    pedals += touch_button("Throttle", "Gaz", width - 74, bottom - 78, 62, 78, (0, 0, 68, 68))
    hand = touch_button("Handbrake", "El freni", width - 66, bottom - 135, 54, 49, (0, 1, 44, 44))
    utility = ""
    x = 12
    for name, label, wide in (("Park", "Park", 50), ("Reverse", "Geri", 50),
                              ("ToggleControls", "Tuşlar", 64), ("Exit", "Çık", 48)):
        utility += touch_button(name, label, x, 6, wide, 48)
        x += wide + 2
    return (group("TouchLeft", steering) + group("TouchPedals", pedals)
            + group("TouchHandbrake", hand) + group("TouchUtility", utility))


HELP_ROWS = (("W / S", "Gaz / geri"), ("A / D", "Sol / sağ"), ("B", "Fren"),
             ("Boşluk", "El freni"), ("P", "Park / sürüş"), ("E", "Araçtan in"), ("H", "Tuşları göster / gizle"))


def help_panel(height, mobile):
    layers = text("ControlsTitle", "Sürüş tuşları", 12, 7, 202, 20, 14, "button-label", center=False)
    for i, (key, label) in enumerate(HELP_ROWS):
        y = 31 + 18 * i
        layers += text(f"Key{i}", key, 12, y, 68, 15, 11, "button-label", center=False)
        layers += text(f"Control{i}", label, 87, y, 131, 15, 11, "button-label", weight=400, center=False)
    return group("Controls", box("ControlPanel", 12, 58 if mobile else height - 221,
                                230, 166, "panel", layers), "help gone")


INTERACTION = """
const stage=document.querySelector('.stage');
const elapsed=matchMedia('(prefers-reduced-motion: reduce)');
const ticks=[...stage.querySelectorAll('.tick')];
let motion=0;
function label(name,value){
 const el=stage.querySelector('[data-n="'+name+'"]');
 if(value!==undefined)el.dataset.t=value;
 return el;
}
function park(on){
 label('ParkStatus').classList.toggle('gone',!on);
 label('HandbrakeStatus').classList.toggle('gone',!on);
 for(const name of ['Park','Handbrake']){
  stage.querySelector('[data-n="'+name+'"]')?.classList.toggle('engaged',on);
 }
}
function setState(state){
 cancelAnimationFrame(motion);
 stage.querySelector('.help').classList.toggle('gone',state!=='help');
 stage.querySelector('[data-n="ToggleControls"]')?.classList.toggle('engaged',state==='help');
 const parked=state==='park';
 park(parked);
 label('Gear',parked?'P':'3');
 const speed=label('Speed'),rpm=label('RPMValue');
 const initial=Number(speed.dataset.t);
 const target=parked?0:84;
 const start=performance.now();
 function frame(now){
  const t=elapsed.matches?1:Math.min((now-start)/360,1);
  const v=Math.round(initial+(target-initial)*(1-Math.pow(1-t,3)));
  label('Speed',v);
  const rev=Math.round((850+v*4000/84)/50)*50;
  rpm.dataset.t=rev.toLocaleString('tr-TR');
  ticks.forEach((tick,i)=>tick.classList.toggle('on',i/(ticks.length-1)<=rev/7600));
  if(t<1)motion=requestAnimationFrame(frame);
 }
 motion=requestAnimationFrame(frame);
}
const toggle=stage.querySelector('[data-n="ShowControls"],[data-n="ToggleControls"]');
toggle.addEventListener('click',()=>setState(stage.querySelector('.help').classList.contains('gone')?'help':'drive'));
stage.querySelector('[data-n="Park"]')?.addEventListener('click',()=>setState(label('Gear').dataset.t==='P'?'drive':'park'));
addEventListener('keydown',event=>{
 if(event.key.toLowerCase()==='h')toggle.click();
});
addEventListener('message',event=>{
 if(event.origin===location.origin && ['drive','park','help'].includes(event.data?.hudState))setState(event.data.hudState);
});
function fit(){
 const zoom=Math.min(1,innerWidth/stage.offsetWidth,innerHeight/stage.offsetHeight);
 stage.style.transformOrigin='top left';
 stage.style.transform='scale('+zoom+')';
}
fit();
addEventListener('resize',fit);
setState('drive');
window.hudPreviewCheck=()=>({
 overflow:[...stage.querySelectorAll('.label:not(.gone)')]
    .filter(node=>node.scrollWidth>node.clientWidth+1 || node.scrollHeight>node.clientHeight+1)
    .map(node=>node.dataset.n),
 dialWidth:stage.querySelector('[data-n="Cockpit"]').offsetWidth,
 stageWidth:stage.offsetWidth,
 stageHeight:stage.offsetHeight
});
"""


def preview(theme, device, size):
    width, height = size
    mobile = device != "desktop"
    body = dial(theme, width, height, mobile) + help_panel(height, mobile)
    if mobile:
        body += touch(width, height)
    else:
        body += group("Toggle", touch_button("ShowControls", "H · Tuşlar", 12, height - 54, 104, 48))
    return (f"<!doctype html><html lang='tr'><meta charset='utf-8'>"
            f"<meta name='viewport' content='width=device-width, initial-scale=1'>"
            f"<title>{theme.name} · {device}</title>"
            f"<style>{STYLE}html,body{{margin:0;overflow:hidden;background:#536b82;font-family:Arial,sans-serif}}</style>"
            f"<div class='stage theme-{theme.key}' style='width:{width}px;height:{height}px;"
            f"{theme.properties()}'>{body}</div><script>{INTERACTION}</script>")


GALLERY = """
const themeButtons=[...document.querySelectorAll('[data-theme]')];
const stateButtons=[...document.querySelectorAll('[data-state]')];
const frames=[...document.querySelectorAll('iframe')];
const phone=document.getElementById('phone');
let theme='a', state='drive', device='mobile';
function send(frame){frame.contentWindow?.postMessage({hudState:state},location.origin)}
function setFrames(){
 const mobileFile=theme+'-'+device+'.html';
 const desktopFile=theme+'-desktop.html';
 phone.style.aspectRatio=device==='mobile'?'844/390':'390/750';
 phone.style.maxWidth=device==='mobile'?'':'320px';
 if(phone.getAttribute('src')!==mobileFile)phone.src=mobileFile;
 if(frames[1].getAttribute('src')!==desktopFile)frames[1].src=desktopFile;
}
for(const frame of frames)frame.addEventListener('load',()=>send(frame));
for(const button of themeButtons)button.onclick=()=>{
 theme=button.dataset.theme;
 for(const other of themeButtons)other.setAttribute('aria-pressed',other===button);
 document.getElementById('note').textContent=button.dataset.note;
 setFrames();
};
for(const button of stateButtons)button.onclick=()=>{
 state=button.dataset.state;
 for(const other of stateButtons)other.setAttribute('aria-pressed',other===button);
 for(const frame of frames)send(frame);
};
document.getElementById('orientation').onclick=event=>{
 device=device==='mobile'?'portrait':'mobile';
 event.currentTarget.textContent=device==='mobile'?'Dikey mobil':'Yatay mobil';
 setFrames();
};
setFrames();
"""


def gallery():
    options = "".join(
        f"<button data-theme='{t.key}' data-note='{escape(t.note, quote=True)}' "
        f"aria-pressed='{str(t.key == 'a').lower()}'>{t.name}</button>" for t in THEMES
    )
    return f"""<!doctype html><html lang="tr"><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A-XZF-Tune · Gösterge seçenekleri</title><style>{BODY}</style>
<main><h1>Gösterge seçenekleri</h1>
<div class="pickers" aria-label="Stil">{options}</div>
<p id="note">{THEMES[0].note}</p>
<div class="options" aria-label="Önizleme durumu">
 <button data-state="drive" aria-pressed="true">Sürüş</button>
 <button data-state="park" aria-pressed="false">Park ve el freni</button>
 <button data-state="help" aria-pressed="false">Tuş yardımı</button>
 <button id="orientation">Dikey mobil</button>
</div>
<div class="devices">
 <figure><figcaption>Mobil · alt orta, yarım daire</figcaption><iframe id="phone" title="Mobil gösterge"></iframe></figure>
 <figure><figcaption>Bilgisayar · sağ alt, çeyrek daire</figcaption>
 <iframe title="Bilgisayar göstergesi" style="aspect-ratio:1056/594"></iframe></figure>
</div>
<p class="review-only">Bir stili uygulamam için adını veya A, B, C harfini yaz.</p>
</main><script>{GALLERY}</script>"""


def build():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / "index.html").write_text(gallery(), encoding="utf-8")
    for theme in THEMES:
        for device, size in (("mobile", PHONE), ("desktop", DESKTOP), ("portrait", PORTRAIT)):
            (OUTPUT / f"{theme.key}-{device}.html").write_text(preview(theme, device, size), encoding="utf-8")


if __name__ == "__main__":
    build()
