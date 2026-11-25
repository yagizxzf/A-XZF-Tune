"""Generate the compact cockpit previews and Studio export pages."""

from pathlib import Path
import html
import math

ROOT = Path(__file__).resolve().parent
AMBER = "#ffbc63"
INK = "#f5f7f8"
MUTED = "#b7c7cd"
TICK_COUNT = 21

CSS = """
*{box-sizing:border-box}
html,body{margin:0;background:#131c21;color:#f5f7f8;font-family:Arial,sans-serif}
#stage{position:relative;overflow:hidden;background:linear-gradient(#42677b,#8faab4)}
.world{position:absolute;inset:0;background:linear-gradient(167deg,transparent 42%,#434b4e 42%,#1e272c)}
.road{position:absolute;left:63%;top:47%;height:78%;width:2px;background:#a8a697;transform:rotate(-33deg)}
.abs{position:absolute}.fill{inset:0}
.grp{pointer-events:none}.grp [data-btn]{pointer-events:auto;cursor:pointer}
.dial,.panel,.gear{background:rgba(14,22,27,.88);border:1px solid #455960}
.dial{border-radius:50%}.panel{border-radius:9px}
.gear{border-radius:5px;background:#3b3024;border-color:#755535}
.face{background:rgba(27,42,48,.6);border:1px solid rgba(163,186,192,.38);border-radius:12px}
.utility{background:rgba(14,22,27,.78);border:1px solid rgba(163,186,192,.38);border-radius:7px}
.down>.face,.down>.utility,[data-btn]:active>.face,[data-btn]:active>.utility{
 background:rgba(110,75,33,.88);border-color:#ffbc63
}
.down [data-n$=Art],[data-btn]:active [data-n$=Art]{filter:brightness(1.18)}
.ot{display:flex;align-items:center;white-space:nowrap;line-height:1}
.ot::after{content:attr(data-t);color:inherit}
.center{justify-content:center}.hid{opacity:0}
main{max-width:58rem;margin:auto;padding:2rem}a{color:#ffbc63;margin-right:1rem}
"""


def box(name, x, y, w, h, cls="", inner="", button=False):
    attr = "data-btn=1" if button else ""
    return (f"<div class='abs {cls}' data-n='{name}' {attr} "
            f"style='left:{x}px;top:{y}px;width:{w}px;height:{h}px'>{inner}</div>")


def text(name, value, x, y, w, h, size, color=INK, weight=400, center=False, hidden=False):
    cls = "abs ot" + (" center" if center else "") + (" hid" if hidden else "")
    label = (f"<span class='{cls}' data-n='{name}' data-t='{html.escape(value, quote=True)}' "
             f"style='inset:0;font-size:{size}px;color:{color};font-weight:{weight}'></span>")
    align = "center" if center else "left"
    return (f"<div class='abs' data-n='{name}Slot' style='text-align:{align};left:{x}px;top:{y}px;"
            f"width:{w}px;height:{h}px'>{label}</div>")


def group(name, anchor, content):
    return f"<div class='abs fill grp' data-g='{name}' data-a='{anchor}'>{content}</div>"


def dashboard(mobile=False, parked=False):
    diameter = 116 if mobile else 198
    mid = diameter / 2
    rim = diameter / 2 - (9 if mobile else 14)
    inner = box("DialRing", 0, 0, diameter, diameter, "dial")
    for i in range(TICK_COUNT):
        degrees = 145 + 250 * i / (TICK_COUNT - 1)
        angle = math.radians(degrees)
        major = i % 5 == 0
        w = (3 if major else 2) * (1 if mobile else 1.5)
        h = (6 if major else 4) * (1 if mobile else 1.5)
        x, y = mid + rim * math.cos(angle) - w / 2, mid + rim * math.sin(angle) - h / 2
        color = (("#ff786a" if i >= 18 else AMBER) if i <= (5 if parked else 13) else "#394a51")
        inner += (f"<div class='abs' data-n='RPM{i}' style='left:{x:.3f}px;top:{y:.3f}px;"
                  f"width:{w}px;height:{h}px;background:{color};border-radius:1px;"
                  f"transform:rotate({degrees + 90}deg)'></div>")

    zoom = diameter / 116

    def line(name, value, x, y, w, h, size, color=INK, weight=400, hidden=False):
        return text(name, value, x * zoom, y * zoom, w * zoom, h * zoom, size * zoom,
                    color, weight, center=True, hidden=hidden)

    inner += line("Speed", "84", 20, 25, 76, 37, 34, weight=700)
    inner += line("Unit", "STUD/S", 20, 62, 76, 13, 9, MUTED, 700)
    inner += box("GearFace", 33 * zoom, 80 * zoom, 22 * zoom, 19 * zoom, "gear")
    inner += line("Gear", "P" if parked else "3", 33, 80, 22, 19, 13, AMBER, 700)
    inner += line("RPM", "4850", 59, 79, 34, 12, 9, INK, 700)
    inner += line("RPMUnit", "RPM", 59, 91, 34, 11, 8, MUTED)
    inner += line("ParkStatus", "PARKED", 3, 114, 72, 14, 10, AMBER, 700, hidden=not parked)
    inner += line("HandbrakeStatus", "HB", 80, 114, 30, 14, 10, AMBER, 700, hidden=not parked)
    if mobile:
        return group("DashboardMobile", "B", box("Cockpit", 902, 938, diameter, 130, inner=inner))
    return group("Dashboard", "BR", box("Cockpit", 1702, 838, diameter, 222, inner=inner))


def controls(mobile=False):
    inner = text("ControlsTitle", "Driving controls", 12, 8, 211, 18, 13, AMBER, 700)
    rows = [("W / S", "Drive / reverse"), ("A / D", "Steer"), ("B", "Brake"),
            ("Space", "Toggle handbrake"), ("P", "Park / drive"),
            ("E", "Exit vehicle"), ("H", "Hide controls")]
    for i, (key, name) in enumerate(rows):
        y = 30 + 19 * i
        inner += text(f"Key{i}", key, 12, y, 78, 17, 12, INK, 700)
        inner += text(f"Control{i}", name, 96, y, 124, 17, 12, MUTED)
    x, y = (12, 62) if mobile else (20, 848)
    panel = box("ControlPanel", x, y, 232, 170, "panel", inner)
    return group("Controls", "TL" if mobile else "BL", panel)


def utility(name, label, x, y, w=48, h=48, face_w=38, face_h=30, active=False):
    inner = box(name + "Face", (w - face_w) / 2, (h - face_h) / 2,
                face_w, face_h, "utility")
    inner += text(name + "Label", label, 4, 0, w - 8, h, 11, INK, 700, center=True)
    return box(name, x, y, w, h, "down" if active else "", inner, button=True)


def physical(name, title, x, y, w, h, art_w, art_h, col, row=None, active=False):
    frame = box(name + "Face", 3, 3, w - 6, h - 6, "face")
    if row is None:
        art = f"url(art/v4/steering-buttons.png);background-size:200% auto;background-position:{col * 100}% 50%"
    else:
        art = f"url(art/v4/control-atlas.png);background-size:200% 200%;background-position:{col * 100}% {row * 100}%"
    frame += (f"<div class='abs' data-n='{name}Art' style='left:{(w-art_w)/2}px;top:{(h-art_h)/2}px;"
              f"width:{art_w}px;height:{art_h}px;background-image:{art}'></div>")
    frame += text(name + "Fallback", title, 4, 0, w - 8, h, 10, INK, 700,
                  center=True, hidden=True)
    return box(name, x, y, w, h, "down" if active else "", frame, button=True)


def touch(parked=False):
    steering = physical("SteerLeft", "SOL", 12, 1012, 54, 56, 48, 66, 0)
    steering += physical("SteerRight", "SAĞ", 72, 1012, 54, 56, 48, 66, 1)
    pedals = physical("Brake", "FREN", 1784, 1008, 60, 60, 48, 48, 1, 0)
    pedals += physical("Throttle", "GAZ", 1850, 994, 58, 74, 66, 66, 0, 0)
    hand = physical("Handbrake", "EL FRENİ", 1856, 938, 52, 48, 42, 42, 0, 1, active=parked)
    actions = "".join(utility(name, value, 12 + 50 * i, 6, active=parked and i == 0)
                      for i, (name, value) in enumerate([
                          ("Park", "P"), ("Reverse", "R"), ("ToggleControls", "TUŞ"), ("Exit", "ÇIK")
                      ]))
    return (group("TouchLeft", "BL", steering) + group("TouchPedals", "BR", pedals)
            + group("TouchHandbrake", "BR", hand) + group("TouchUtility", "TL", actions))


TOGGLE = group("Toggle", "BL", utility("ShowControls", "H · CONTROLS", 20, 1022,
                                      116, 38, 116, 32))
RECOVERY = group("Recovery", "T", box("RecoveryPanel", 830, 8, 260, 34, "panel",
                 text("RecoveryText", "Waiting for space", 8, 0, 244, 34, 13, AMBER, 700, center=True)))


def page(name, body, mobile=False):
    # Exports use the canonical stage. Browser preview re-anchors the same named groups
    # at a phone or desktop viewport size while retaining their logical-pixel dimensions.
    width, height = (844, 390) if mobile else (1280, 720)
    script = f"""
const stage = document.getElementById('stage');
const raw = new URLSearchParams(location.search).has('raw');
const width = raw ? 1920 : {width};
const height = raw ? 1080 : {height};
stage.style.width = width + 'px';
stage.style.height = height + 'px';
if (!raw) {{
  for (const group of stage.querySelectorAll('[data-g]')) {{
    const anchor = group.dataset.a;
    const x = anchor.includes('R') ? width - 1920 : anchor.includes('L') ? 0 : (width - 1920) / 2;
    const y = anchor.includes('B') ? height - 1080 : 0;
    group.style.translate = x + 'px ' + y + 'px';
  }}
  const fit = () => {{
    stage.style.transformOrigin = 'top left';
    stage.style.transform = 'scale(' + Math.min(1, innerWidth / width, innerHeight / height) + ')';
  }};
  fit();
  addEventListener('resize', fit);
}}
window.checkOverflow = () => ({{
  overflow: [...document.querySelectorAll('span[data-n]')]
    .filter(e => e.scrollWidth > e.clientWidth + 1 || e.scrollHeight > e.clientHeight + 1)
    .map(e => e.dataset.n),
  broken: [...document.images].filter(e => !e.complete || !e.naturalWidth).map(e => e.src)
}});
"""
    markup = (f"<!doctype html><meta charset='utf-8'><title>A-XZF-Tune · {name}</title>"
              f"<style>{CSS}</style><div id='stage'><div class='world'><div class='road'></div></div>"
              f"{body}</div><script>{script}</script>")
    (ROOT / (name + ".html")).write_text(markup, encoding="utf-8")


page("hud", dashboard() + controls() + TOGGLE)
page("hud_phone", dashboard(mobile=True) + touch(), mobile=True)
page("states", dashboard(parked=True) + controls() + TOGGLE + RECOVERY)
page("templates", touch() + RECOVERY)
page("mobile_states", dashboard(mobile=True, parked=True) + touch(parked=True), mobile=True)
page("mobile_help", dashboard(mobile=True) + touch() + controls(mobile=True), mobile=True)

LINKS = ("<a href='hud_phone.html'>Phone</a><a href='mobile_states.html'>Parked phone</a>"
         "<a href='mobile_help.html'>Phone help</a><a href='hud.html'>Desktop</a>"
         "<a href='states.html'>Desktop help and recovery</a>")
for name in ("style", "index"):
    (ROOT / (name + ".html")).write_text(
        f"<!doctype html><meta charset='utf-8'><title>A-XZF-Tune HUD</title><style>{CSS}</style>"
        f"<main><h1>A-XZF-Tune driving HUD</h1>{LINKS}</main>", encoding="utf-8")
print("Built compact cockpit previews")
