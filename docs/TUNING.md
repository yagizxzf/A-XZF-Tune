# Tune schema 1

Put a ModuleScript named `Tune` directly under your vehicle. Return only overrides:

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

RPM thresholds must satisfy `IdleRPM < ShiftDownRPM < ShiftUpRPM < RedlineRPM`. Travel must exceed static sag plus 0.1 studs. Schema numbers do not automatically scale with the model.

## Presets and surfaces

`ReplicatedStorage.AXZF.Shared.Presets` offers Street, Touring (FWD), Rally (AWD/travel) and Drift (less grip/more steering/torque). These are starting points, not validated real-car specifications. `Tune.resolve(Presets.Rally)` supplies the rest of the defaults.

Set a numeric `Grip` attribute on a track BasePart. Values are clamped to 0.05..3 and multiply Tune.Grip. For example 0.3 is slippery. Missing/nonfinite values use 1. Terrain uses its Instance's attribute; this version has no per-material tire database.

Tune in this order: size/orientation/mounts → static sag → damping → grip → steering → torque/gears → brakes. Re-run the driving harness after substantial changes. [Equations and fidelity](ARCHITECTURE.md).
