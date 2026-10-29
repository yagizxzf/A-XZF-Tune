# Circular cockpit and inputs

The independently drawn dial displays actual speed, units, gear, RPM and parking state. The developer explicitly approved the circular HTML design before Studio import. No A-Chassis UI code or art was copied.

| Action | Keyboard | Gamepad | Touch |
|---|---|---|---|
| Forward/reverse | W/S | RT/LT | GO/REVERSE, hold |
| Steer | A/D | left stick | LEFT/RIGHT, hold |
| Brake | B | B | BRAKE, hold |
| Toggle parking brake | Space | A | PARK, tap |
| Exit | E | Y | EXIT, tap |
| Hide/show help | H | keyboard binding | KEYS, tap |

PARK toggles; releasing Space leaves it engaged. Help can hide independently of driving buttons. Tune.Controls overrides unique keyboard key-name strings; partial maps inherit defaults. Tune.ShowControls sets initial help visibility. SpeedScale/SpeedUnit change display only. Rebind/restart Play after editing Tune.

VehicleSeat.HeadsUpDisplay is disabled while bound and restored on destroy. Character TouchGui is hidden while driving, including when created after a device change, and restored on exit. Focus loss, chat, death and exit clear held input. Global release handles dragging off a touch/mouse button.

Studio layout checks: iPhone 7 landscape, iPhone 13 landscape/portrait, iPad 6th generation landscape. Inspected buttons are at least 48×48 logical pixels, with no button/button or button/dial overlaps. Mobile GO/PARK/KEYS/EXIT were exercised by simulator input. Physical multitouch/gamepad, console focus, localization expansion and accessibility text scaling remain adoption tests.

Visual source: ui/build.py + ui/rbx.json. Generated Data modules define the native GUI; Cockpit.luau binds and lays it out. Builder is credited MIT tooling. The optional export uses the installed roblox-ui-maker tools; the normal package build needs no HTML export tools or external icons.
