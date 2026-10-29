# Circular cockpit and inputs

The independently drawn dial displays actual speed, units, gear, RPM and parking state. The developer explicitly approved the circular HTML design before Studio import. No A-Chassis UI code or art was copied.

| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Forward/reverse | W/S | RT/LT | GAZ/GERİ, hold |
| Steer | A/D | left stick | LEFT/RIGHT, hold |
| Brake | B | B | BRAKE, hold |
| Toggle rear handbrake | Space | A | EL FRENİ, tap |
| Park / drive | P | X | PARK, tap |
| Exit | E | Y | EXIT, tap |
| Hide/show help | H | keyboard binding | KEYS, tap |

PARK and EL FRENİ toggle independently. Park displays P plus Stopping/Parked status; the rear handbrake displays HB. Releasing Space leaves the handbrake engaged. Help can hide independently of driving buttons. Tune.Controls overrides unique keyboard key-name strings; partial maps inherit defaults. Tune.ShowControls sets initial help visibility. SpeedScale/SpeedUnit change display only. Rebind/restart Play after editing Tune.

VehicleSeat.HeadsUpDisplay is disabled while bound and restored on destroy. Character TouchGui is hidden while driving, including when created after a device change, and restored on exit. Focus loss, chat, death and exit clear held input. Global release handles dragging off a touch/mouse button.

Studio layout checks: iPhone 7 landscape, iPhone 13 landscape/portrait, iPad 6th generation landscape. Inspected buttons are at least 48×48 logical pixels, with no button/button or button/dial overlaps. Mobile GO/PARK/KEYS/EXIT were exercised by simulator input. Physical multitouch/gamepad, console focus, localization expansion and accessibility text scaling remain adoption tests.

Visual source: ui/build.py + ui/rbx.json. Generated Data modules define the native GUI; Cockpit.luau binds and lays it out. Builder is credited MIT tooling. The optional export uses the installed roblox-ui-maker tools; the normal package build needs no HTML export tools or external icons.

Hotfix verification: the original A-XZF-Tune place72435697524161 was updated directly. GUI appears on prototype/imported driver-seat entry, H hides help, E exits/hides HUD, and respawn/re-entry retains exactly one cockpit. Fleet now prepares the template without special Bootstrap UI code. GUI dependencies wait for replication and report missing package/template after15 seconds.

## 0.3 icon controls

The developer approved the icon-button preview before import. Nine monochrome Lucide icons cover gas, brake, handbrake, park, reverse, exit, help and left/right steering. Labels remain live text; held/toggled buttons receive amber feedback. Sources and attribution are in ui/icon-pack/provenance.json and licenses/Lucide-LICENSE.txt; image upload results are ui/assets.json. `circle_parking` is an action alias for Lucide's circle-pause icon.

Current checks: iPhone 7 (666×374 GUI viewport), iPhone 13 (749×388), iPad A16 (1179×819), landscape. All nine icons loaded; one cockpit; no button/help/dial overlap after the small-phone dial adjustment. Smallest hit targets are 84.5×58.5 logical pixels. On a narrow phone the dial shrinks while keyboard help is open and expands when hidden. The current place is LandscapeSensor; 0.3 portrait, physical multitouch and gamepad were not exercised.

Simulator input verified gas 1→0 on drag-out release, brake=1, left/right=-1/+1, reverse=-1, separate handbrake/park toggles, hiding help without hiding buttons, exit restoring native TouchGui, and re-entry displaying P for retained parking. Main original Studio also shows P/PARK ON separately from HB ON with the native seat HUD disabled.

Optional HTML authoring: install @resvg/resvg-js under .tools/svg, run `node ui/render_icons.mjs`, then copy_icons.py from ui/ using icons.json and icon-pack/png. Normal `python tools/build.py` uses committed runtime modules and requires no icon toolchain. Reuse ui/assets.json through ledger.py; do not re-upload unchanged icons.
