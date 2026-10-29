# Bring your own model

Use a **separate copy** of your artwork. The adapter binds real parts, not a screenshot or one-piece substitute. Remove previous chassis scripts, remotes, joints, constraints, actuators and body movers first; keep an untouched backup. Never run unknown Toolbox scripts to test their safety.

```text
MyCar (Model) [tag AXZFVehicle]
  Chassis (BasePart; local -Z points forward)
    FL, FR, RL, RR (Attachment spring tops)
  DriveSeat (VehicleSeat)
  Body (Folder or Model: doors, hood, roof, glass, bumpers...)
  Wheels (Folder or Model)
    FL (Model with PrimaryPart or one BasePart)
    FR
    RL
    RR
  Tune (optional ModuleScript returning overrides)
```

Coordinates are Chassis-local: left is -X, front is -Z, up is +Y. `FL` = front-left. Keep root and seat directly under the top-level model. Model.PrimaryPart should be Chassis. Each multi-part wheel needs a hub assigned to its PrimaryPart; rim, tire and other wheel subparts are welded to that hub at bind. Other panels are welded to Chassis. Cosmetic wheel parts are non-colliding/massless; Chassis supplies collision and mass. Tune Radius is the same for all four wheels in this version. Separate front/rear tire radii need a future schema extension.

Place spring-top attachments above each wheel center by `RestLength`. At equilibrium the spring sags by `workspace.Gravity/(2*pi*FrequencyHz)^2`; leave sufficient travel and body clearance. The wheel's authored orientation is preserved. Its axle should face Chassis local X. Chassis should have a sensible collision box and center of mass; wheelbase/track alone cannot repair a high or off-center body.

## Explicit adapter

For unconfigured geometry with no existing Body/Wheels folders:

```lua
local Adapter = require(game.ServerScriptService.AXZFServer.Adapter)
local model = workspace.MyCar
local wheelMap = {FL=model.FrontLeft, FR=model.FrontRight, RL=model.RearLeft, RR=model.RearRight}
local report = Adapter.prepare(model, model.PrimaryPart, model.VehicleSeat, wheelMap, 1.6)
assert(report.ok, game.HttpService:JSONEncode(report.errors))
```

Run in Edit mode on the backup copy. This creates Body/Wheels/mounts and normalizes names. It does **not** guess which of hundreds of artist meshes is a wheel or erase unknown old mechanics. Already configured rigs use Doctor instead. Non-sibling/nested wheel references should be flattened first.

```lua
local report = require(game.ServerScriptService.AXZFServer.Doctor).inspect(workspace.MyCar)
print(game:GetService("HttpService"):JSONEncode(report))
```

| Code | Fix |
|---|---|
| ROOT / SEAT / BODY / WHEELS | Add the named instance in the contract |
| MOUNT_FL etc. | Create the matching Chassis Attachment |
| HUB_FL etc. | Set wheel Model.PrimaryPart or supply a BasePart |
| LAYOUT / SPACING | Correct front/left labels, orientation and distinct positions |
| SCRIPT | Remove former vehicle executable content; only authored root Tune is allowed |
| MECHANICS | Remove old joints/constraints including WeldConstraints |
| PART_COUNT (warning) | More than 200 physical parts; measure your target device |

## Real-art example

[CreatorCarAdapter.luau](../examples/CreatorCarAdapter.luau) demonstrates a real 47-part car, including distinct mesh panels and multi-part wheels. [ASSETS.md](ASSETS.md) records the exact source, inspection and exclusions. It clones geometry only, replaces the original chassis entirely and removes inaccessible texture dependencies. Inspect/obtain the model separately before calling it.

## Common issues

Car falls through: check Chassis collision and surface eligibility. Car bottoms out: increase frequency/travel, check Radius and mounts. Car turns the wrong way: root forward is -Z and wheel labels must follow local axes. Car launches: inspect scale, overlap and center of mass; do not copy force values from another chassis. Cannot move: read AXZFError, ensure only one Bootstrap, confirm the actual player occupies DriveSeat, then check watchdog/commands. A single ray per wheel can miss curbs; use smooth track geometry for the current backend.
