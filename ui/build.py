"""Build the monochrome HUD previews and the native GUI export pages."""

from html import escape
import math
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent
ICONS = ET.parse(ROOT / "art/hud-icons.svg").getroot()
SVG_NS = "{http://www.w3.org/2000/svg}"
TICK_COUNT = 15
MOBILE_RADIUS = 110
DESKTOP_RADIUS = 204

CSS = """
*{box-sizing:border-box}
html,body{margin:0;background:#17232a;color:#f7f7f7;font-family:Arial,sans-serif}
#stage{position:relative;overflow:hidden;isolation:isolate;background:#4d606c
 url(rbx/out/hud-review/scene.jpg) center/cover no-repeat}
.abs{position:absolute}.fill{inset:0}
.grp{pointer-events:none}.grp [data-btn]{pointer-events:auto;cursor:pointer;touch-action:none}
.dial{border:1px solid rgba(255,255,255,.42);border-radius:50%;background:rgba(8,10,12,.29)}
.tick{stroke:rgba(255,255,255,.26);transition:stroke 110ms}.tick.live{stroke:#f7f7f7}
.face{background:rgba(8,10,12,.25);border:1px solid rgba(255,255,255,.39);border-radius:9px;
 transition:transform 110ms,background-color 110ms}
.panel{background:rgba(8,10,12,.74);border:1px solid rgba(255,255,255,.34);border-radius:9px}
.gear{border:1px solid rgba(255,255,255,.56);border-radius:5px;background:rgba(8,10,12,.24)}
[data-btn]:active .face{transform:scale(.94)}
[data-btn]:active .face,.engaged .face{background:rgba(255,255,255,.23);border-color:#fff}
.ot{display:flex;align-items:center;white-space:nowrap;line-height:1}
.ot::after{content:attr(data-t);color:inherit}
.center{justify-content:center}.hid{opacity:0}
.label-muted{color:#d5d5d5}
.dial-text{font-variant-numeric:tabular-nums;-webkit-text-stroke:.53px rgba(0,0,0,.75)}
.dial-text.label-muted{color:#eeeeee;-webkit-text-stroke:.3px rgba(0,0,0,.75)}
.help{transition:opacity 160ms}.help.hidden-preview{opacity:0}
.entering{animation:appear 235ms cubic-bezier(.22,.65,.27,1)}
@keyframes appear{from{transform:translateY(13px);opacity:.45}to{transform:translateY(0);opacity:1}}
@media(prefers-reduced-motion:reduce){*{transition:none!important;animation:none!important}}
main{max-width:58rem;margin:auto;padding:2rem}a{color:#f0f0f0;margin-right:1rem}
"""


def box(name, x, y, w, h, cls="", content="", button=None):
    marker = f"data-btn='1' role='button' aria-label='{escape(button)}'" if button else ""
    return (f"<div class='abs {cls}' data-n='{name}' {marker} "
            f"style='left:{x}px;top:{y}px;width:{w}px;height:{h}px'>{content}</div>")


def text(name, value, x, y, w, h, size, cls="", weight=700, center=True):
    label = (f"<span class='abs ot {'center' if center else ''} {cls}' data-n='{name}' "
             f"data-t='{escape(value, quote=True)}' style='inset:0;font-size:{size}px;"
             f"font-weight:{weight}'></span>")
    align = "center" if center else "left"
    return (f"<div class='abs' data-n='{name}Slot' style='text-align:{align};left:{x}px;top:{y}px;"
            f"width:{w}px;height:{h}px'>{label}</div>")


def group(name, anchor, content, cls=""):
    return f"<div class='abs fill grp {cls}' data-g='{name}' data-a='{anchor}'>{content}</div>"


def svg(w, h, lines):
    return (f"<svg class='abs' aria-hidden='true' style='inset:0' xmlns='http://www.w3.org/2000/svg' "
            f"width='{w}' height='{h}' viewBox='0 0 {w} {h}' fill='none' "
            f"stroke-linecap='round'>{lines}</svg>")


def icon(name, icon_id, x, y):
    source = next(node for node in ICONS if node.get("id") == icon_id)
    lines = []
    for polyline in source.findall(SVG_NS + "polyline"):
        points = [pair.split(",") for pair in polyline.attrib["points"].split()]
        for (x1, y1), (x2, y2) in zip(points, points[1:]):
            lines.append(f"<line data-n='{name}Line{len(lines)}' x1='{x1}' y1='{y1}' x2='{x2}' y2='{y2}' "
                         f"stroke='{ICONS.get('stroke')}' stroke-width='{ICONS.get('stroke-width')}'/>")
    return box(name, x, y, 24, 24, "hid", svg(24, 24, "".join(lines)))


def dashboard(width, height, mobile, raw=False, parked=False):
    radius = MOBILE_RADIUS if mobile else DESKTOP_RADIUS
    diameter = radius * 2
    if raw:
        x = (width - diameter) // 2 if mobile else width - diameter - 24
        y = height - diameter - 24
    else:
        x = width // 2 - radius if mobile else width - radius
        y = height - radius
    inner = box("DialRing", 0, 0, diameter, diameter, "dial")
    lines = []
    for i in range(TICK_COUNT):
        angle = math.radians(183 + (174 if mobile else 84) * i / (TICK_COUNT - 1))
        length = 7 if i in (0, 7, 14) else 4
        endpoints = tuple(round(radius + offset * fn(angle), 2)
                          for offset in (radius - 8 - length, radius - 8) for fn in (math.cos, math.sin))
        lit = " live" if i / (TICK_COUNT - 1) <= (.12 if parked else .61) else ""
        lines.append(f"<line data-n='RPM{i}' class='tick{lit}' stroke-width='1.5' "
                     f"x1='{endpoints[0]}' y1='{endpoints[1]}' x2='{endpoints[2]}' y2='{endpoints[3]}'/>")
    inner += svg(diameter, diameter, "".join(lines))
    if mobile:
        speed, unit = (61, 27, 98, 39, 36), (57, 65, 106, 12, 10)
        gear, rpm, status = (68, 80, 29, 20), (106, 80, 69, 20), (50, 19, 120, 10)
    else:
        speed, unit = (76, 51, 115, 69, 58), (71, 116, 125, 15, 13)
        gear, rpm, status = (72, 145, 36, 29), (114, 145, 78, 29), (72, 178, 125, 13)
    gx, gy, gw, gh = gear
    rx, ry, rw, rh = rpm
    sx, sy, sw, sh = status
    inner += text("Speed", "0" if parked else "84", *speed, "dial-text")
    inner += text("Unit", "stud/sn", *unit, "dial-text label-muted", weight=600)
    inner += box("GearFace", gx, gy, gw, gh, "gear")
    inner += text("Gear", "P" if parked else "3", gx, gy, gw, gh, 13 if mobile else 20)
    inner += text("RPMValue", "850 dev/dk" if parked else "4.850 dev/dk", rx, ry, rw, rh,
                  10 if mobile else 12, "dial-text label-muted")
    state = "dial-text" if parked else "dial-text hid"
    inner += text("ParkStatus", "Parkta", sx, sy, sw / 2, sh, 8 if mobile else 10, state)
    inner += text("HandbrakeStatus", "El freni", sx + sw / 2, sy, sw / 2, sh, 8 if mobile else 10, state)
    return group("DashboardMobile" if mobile else "Dashboard", "B" if mobile else "BR",
                 box("Cockpit", x, y, diameter, diameter, "" if raw else "entering", inner))


def button(name, title, x, y, w, h, glyph=None, engaged=False):
    # The inner face is only visual; the rectangle around it receives touches.
    inset_x, inset_y = (5, 5) if glyph else (3, 9)
    inner = box(name + "Face", inset_x, inset_y, w - 2 * inset_x, h - 2 * inset_y, "face")
    if glyph:
        inner += (f"<img class='abs' data-n='{name}Art' alt='' src='art/minimal-controls/{glyph}.png' "
                  f"style='left:{(w - 28) / 2}px;top:{(h - 28) / 2}px;width:28px;height:28px'>")
        inner += icon(name + "Icon", glyph, (w - 24) / 2, (h - 24) / 2)
    else:
        inner += text(name + "Label", title, 3, 0, w - 6, h, 11, weight=600)
    return box(name, x, y, w, h, "engaged" if engaged else "", inner, button=title)


def touch(width, height, parked=False):
    bottom = height - 12 - (MOBILE_RADIUS + 8 if width < 468 else 0)
    steer = button("SteerLeft", "Sol", 12, bottom - 48, 48, 48, "left")
    steer += button("SteerRight", "Sağ", 66, bottom - 48, 48, 48, "right")
    pedals = button("Brake", "Fren", width - 118, bottom - 48, 48, 48, "brake")
    pedals += button("Throttle", "Gaz", width - 64, bottom - 54, 52, 54, "gas")
    hand = button("Handbrake", "El freni", width - 60, bottom - 108, 48, 48, "handbrake", parked)
    actions = [
        ("Park", "Park", 12, 48), ("Reverse", "Geri", 62, 48),
        ("ToggleControls", "Tuşlar", 112, 54), ("Exit", "Çık", 168, 48),
    ]
    utility = "".join(button(name, title, x, 6, w, 48, engaged=parked and name == "Park")
                      for name, title, x, w in actions)
    return (group("TouchLeft", "BL", steer) + group("TouchPedals", "BR", pedals)
            + group("TouchHandbrake", "BR", hand) + group("TouchUtility", "TL", utility))


def controls(height, mobile, visible):
    rows = [("W / S", "Gaz / geri"), ("A / D", "Sol / sağ"), ("B", "Fren"), ("Boşluk", "El freni"),
            ("P", "Park / sürüş"), ("E", "Araçtan in"), ("H", "Tuş yardımını aç / kapat")]
    inner = text("ControlsTitle", "Sürüş tuşları", 10, 7, 206, 18, 13, center=False)
    for i, (key, action) in enumerate(rows):
        y = 29 + 17 * i
        inner += text(f"Key{i}", key, 10, y, 70, 15, 11, center=False)
        inner += text(f"Control{i}", action, 89, y, 132, 15, 11, "label-muted", 400, False)
    return group("Controls", "TL" if mobile else "BL",
                 box("ControlPanel", 12, 59 if mobile else height - 223, 232, 154, "panel", inner),
                 "help" + ("" if visible else " hidden-preview"))


def recovery(width):
    label = text("RecoveryText", "Düzeltme için alan bekleniyor", 8, 0, 210, 32, 11)
    return group("Recovery", "T", box("RecoveryPanel", width // 2 - 113, 8, 226, 32, "panel", label))


def layout(width, height, mobile, raw, parked, help_open, recovering):
    content = dashboard(width, height, mobile, raw, parked)
    content += controls(height, mobile, raw or help_open)
    if mobile:
        content += touch(width, height, parked)
    else:
        content += group("Toggle", "BL", button("ShowControls", "H · Tuşlar", 12, height - 58, 95, 48))
    if recovering:
        content += recovery(width)
    return f"<div id='stage' style='width:{width}px;height:{height}px'>{content}</div>"


SCRIPT = """
const stage=document.getElementById('stage');
const panel=stage.querySelector('.help');
const toggle=stage.querySelector('[data-n=ShowControls],[data-n=ToggleControls]');
function toggleHelp(){
  const hidden=panel.classList.toggle('hidden-preview');
  toggle.classList.toggle('engaged',!hidden);
}
toggle.addEventListener('click',toggleHelp);
addEventListener('keydown',event=>{if(event.key.toLowerCase()==='h')toggleHelp();});
function fit() {
  stage.style.transformOrigin='top left';
  stage.style.transform='scale('+Math.min(1,innerWidth/stage.offsetWidth,innerHeight/stage.offsetHeight)+')';
}
fit();
addEventListener('resize',fit);
window.checkOverflow=()=>({
  overflow:[...stage.querySelectorAll('span[data-n]:not(.hid)')]
    .filter(e=>e.scrollWidth>e.clientWidth+1||e.scrollHeight>e.clientHeight+1).map(e=>e.dataset.n),
  broken:[...document.images].filter(e=>!e.complete||!e.naturalWidth).map(e=>e.src)
});
"""


def page(name, mobile=False, parked=False, help_open=False, recovering=False, portrait=False):
    width, height = (390, 750) if portrait else (844, 390) if mobile else (1280, 720)
    preview = layout(width, height, mobile, False, parked, help_open, recovering)
    export = layout(1920, 1080, mobile, True, parked, help_open, recovering)
    markup = (f"<!doctype html><html lang='tr'><meta charset='utf-8'>"
              "<meta name='viewport' content='width=device-width, initial-scale=1'>"
              f"<title>A-XZF-Tune · Sürüş göstergesi</title><style>{CSS}</style><body>"
              f"<template id='preview'>{preview}</template><template id='native'>{export}</template>"
              "<script>const raw=new URLSearchParams(location.search).has('raw');"
              "document.body.append(document.getElementById(raw?'native':'preview').content.cloneNode(true));"
              f"if(!raw){{{SCRIPT}}}</script>")
    (ROOT / (name + ".html")).write_text(markup, encoding="utf-8")


if __name__ == "__main__":
    page("hud")
    page("hud_phone", mobile=True)
    page("states", parked=True, help_open=True, recovering=True)
    page("templates", mobile=True, recovering=True)
    page("mobile_states", mobile=True, parked=True)
    page("mobile_help", mobile=True, help_open=True)
    page("mobile_portrait", mobile=True, portrait=True)
    for name in ("index", "style"):
        (ROOT / (name + ".html")).write_text(
            f"<!doctype html><html lang='tr'><meta charset='utf-8'><title>A-XZF-Tune HUD</title>"
            f"<style>{CSS}</style><main><h1>Sürüş göstergesi</h1>"
            "<a href='hud_phone.html'>Mobil</a><a href='mobile_portrait.html'>Dikey mobil</a>"
            "<a href='hud.html'>Bilgisayar</a><a href='mobile_states.html'>Park</a>"
            "<a href='mobile_help.html'>Tuş yardımı</a></main>", encoding="utf-8")
    print("HUD önizlemeleri hazır")
