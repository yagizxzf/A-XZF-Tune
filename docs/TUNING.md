# Tune schema 1

Put a ModuleScript named `Tune` directly under your vehicle. Return only overrides:

Clone ServerStorage.AXZFExamples.VehicleTune into your car and rename it Tune for a commented Turkish tutorial. Prototype, migration and CreatorCarAdapter create it automatically; the public kit includes it.

```lua
return {
    SchemaVersion = 1,
    Drive = "AWD",
    Radius = 1.25,
    RestLength = 2,
    FrequencyHz = 3,
    Grip = 1.35,
}
```

The server resolves and freezes a private copy. Unknown keys, unsupported schema, NaN/Inf, invalid ranges, unsorted curves and non-descending gear ratios fail with explanations. Root Tune is trusted **server code**: author it yourself; never retain a downloaded model's arbitrary Tune module. Changes take effect on the next bind; there is no implicit live config service or persistence.

All dynamics use **Roblox mass/stud/second units**, not SI kilograms/meters. Measured telemetry speed is studs/s. Do not label it km/h without an explicit project scale conversion.

| Field | Default | Allowed / meaning |
|---|---|---|
| SchemaVersion | 1 | exactly 1 |
| Drive | RWD | FWD / RWD / AWD |
| Radius | 1.25 | 0.1..10 studs, all wheels |
| RestLength | 1.6 | 0.1..10 studs, full spring extension |
| FrequencyHz | 3.5 | 1..12; mass-derived stiffness |
| DampingRatio | 0.85 | 0.1..3; higher settles faster, excessive damping feels harsh |
| MaxLoad | 4 | 1..10 times static corner weight |
| RollInfluence | 0.2 | 0..1; vertical tyre force lever arm, lower reduces body roll/pitch |
| AntiRoll | 0.5 | 0..2; equal/opposite axle spring-load transfer, only with both contacts |
| RollDamping | 4 | 0..20 per second; roll-velocity damping with at least two contacts; no airborne orientation lock |
| ParkOnSpawn | false | starts with parking requested |
| AutoParkOnExit | false | request parking when a human driver leaves |
| ParkBrakeAcceleration | 140 | 1..500 studs/s²; four-wheel parking brake demand, traction limited |
| ParkEngageSpeed | 1.5 | 0.1..3 studs/s; Stopping/Parked telemetry threshold |
| Grip | 1.2 | 0.05..3; tire friction coefficient |
| LateralResponse | 12 | 0.1..40 per second, lateral velocity correction demand |
| BrakeAcceleration | 90 | 1..500 studs/s² before traction cap |
| HandbrakeAcceleration | 110 | 1..500, rear contacts only |
| RollingResistance | 0.015 | 0..0.2 times contact normal load |
| Drag | 0.025 | 0..2; quadratic drag coefficient in Roblox units |
| SteerDegrees | 32 | 1..60 maximum center steering angle |
| SteerResponse | 7 | 0.1..30 exponential response per second |
| SteerFadeSpeed | 100 | 1..500 studs/s; speed-based angle reduction |
| MinSteerFraction | 0.28 | 0.05..1 minimum angle fraction at speed |
| IdleRPM | 850 | 100..5000 |
| RedlineRPM | 7000 | 1000..20000 |
| ShiftUpRPM | 6100 | 500..20000 |
| ShiftDownRPM | 2100 | 100..10000 |
| ShiftTime | 0.3 | 0.05..3 seconds; shift cooldown / torque reduction |
| FinalDrive | 3.7 | 0.1..15 |
| ReverseRatio | 3.1 | 0.1..10 |
| Gears | {3.2,2.1,1.5,1.12,0.88} | 1..10 strictly descending positive ratios |
| TorqueCurve | {{850,95},{2500,150},{4500,175},{7000,110}} | 2..32 {RPM, torque} points; strictly increasing finite RPM, torque 0..100000 |
| TorqueScale | 4 | 0.1..100; converts authored curve torque to Roblox torque |
| InputTimeout | 0.35 | 0.1..2 seconds; expired controls apply brakes |
| TelemetryHz | 10 | 1..20 attribute updates/second |
| SleepAfter | 3 | 0..30 seconds settled; suppresses wheel visual updates, not gravity support |
| Power | 1 | 0.1..5 force multiplier, not real horsepower |
| MaxSpeed | 180 | 5..600 studs/s; cuts motor thrust, does not clamp downhill speed |
| Mass | 0 | 0..5000 Roblox mass; 0 keeps Chassis properties; nonzero must fit density 0.01..100 |
| AutoRecover | true | boolean; inverted, slow, grounded and target-space-clear recovery |
| RecoverDelay | 2 | 0.5..15 seconds continuously eligible |
| RecoverMaxSpeed | 6 | 0.1..15 studs/s; recovery also requires vertical speed <=3 |
| VFX | true | rear contact effects enabled |
| VFXIntensity | 1 | 0..2 particle count multiplier |
| SpeedScale | 1 | 0.01..10 display multiplier only |
| SpeedUnit | STUD/S | 1..12-character display label |
| ShowControls | true | initial help visibility; H/KEYS toggles it |
| Controls | below | unique keyboard key-name strings; partial maps inherit defaults |

```lua
Controls = {Forward="W", Reverse="S", Left="A", Right="D",
    Brake="B", Handbrake="Space", Park="P", Exit="E", HideControls="H"}
```

Letters A..Z, Space, Left/RightShift, Left/RightControl, Up/Down/Left/Right and One..Five are supported. Duplicate bindings fail validation. Gamepad/touch are independent of keyboard remaps. Space/EL FRENİ toggles the rear handbrake. P/PARK is a separate latched parking mode. See [HUD](HUD.md) and [VFX](VFX.md).

RPM thresholds must satisfy `IdleRPM < ShiftDownRPM < ShiftUpRPM < RedlineRPM`. Travel must exceed static sag plus 0.1 studs. Schema numbers do not automatically scale with the model.

## Presets and surfaces

`ReplicatedStorage.AXZF.Shared.Presets` offers Street, Touring (FWD), Rally (AWD/travel) and Drift (less grip/more steering/torque). These are starting points, not validated real-car specifications. `Tune.resolve(Presets.Rally)` supplies the rest of the defaults.

Set a numeric `Grip` attribute on a track BasePart. Values are clamped to 0.05..3 and multiply Tune.Grip. For example 0.3 is slippery. Missing/nonfinite values use 1. Terrain uses its Instance's attribute; this version has no per-material tire database.

Tune in this order: size/orientation/mounts → static sag → damping → grip → steering → torque/gears → brakes. Re-run the driving harness after substantial changes. [Equations and fidelity](ARCHITECTURE.md).

## Complete in-car tutorial and upgrades (0.3)

Both cars in the original Studio now have the complete commented Turkish `Tune`, with all 49 supported top-level fields and nine control bindings. Motor curve, gear ratios/RPM, power/speed/mass, springs, roll stability, grip/steering/brakes, parking/recovery, HUD/VFX and network timing are editable there. Stop Play, change one value, restart Play. The factory, migration tool and CreatorCarAdapter use the same template.

Editor helper (does not evaluate the existing Tune):

```lua
local Editor = require(game.ServerScriptService.AXZFServer.TuneEditor)
-- New vehicle without Tune: documented defaults.
Editor.install(workspace.MyCar, nil)
-- Existing vehicle: explicitly supply your current authored AXZF overrides.
Editor.install(workspace.MyCar, {Drive="FWD", Radius=1.5, TorqueScale=5})
```

Passing nil when Tune already exists is refused to prevent silent loss of values. Supply all existing overrides you want to keep. This helper is Edit-only and uses ScriptEditorService to synchronize open source editors. Never pass values obtained by requiring a downloaded A-Chassis Tune; migrate its geometry first.

Upgrade note: P now defaults to **Park**. If a 0.2 car remapped Handbrake to P, set Park to another unique key (e.g. O), or restore Handbrake to Space. Duplicate keys are rejected with an explanation.

## Parking and body roll

P cuts engine thrust and brakes all four wheels. Moving requests report `Stopping`; below ParkEngageSpeed they report `Parked`. Repeating P releases parking. The request survives driver exit and input timeout; Space remains independent. Gravity compensation at low speed reduces slope creep, within configured brake/tyre grip limits. No anchoring or position/velocity teleport is used. Ice, very steep slopes and external collisions can still move a parked vehicle.

RollInfluence reduces the vertical tyre-force lever arm while preserving its yaw lever arm. AntiRoll transfers bounded, equal/opposite normal loads across grounded axle pairs. RollDamping damps angular roll velocity without imposing a world-up orientation. Set `RollInfluence=1, AntiRoll=0, RollDamping=0` for the older body-roll response. First fix wheel radius/mount geometry and excessive centre-of-mass height; raising Grip alone is not a roll fix.
