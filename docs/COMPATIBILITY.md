# Compatibility results — 0.2.0-rc.1

Measured 2026-10-29 in the local A-XZF compatibility lab. These are three actual free Creator Store A-Chassis cars, acquired separately into inert ServerStorage. Legacy Tune headers were inspected as text; **no legacy ModuleScript/plugin/Script was executed**. Geometry was migrated to a fresh AXZF rig. Original packages remained intact.

| Model / listing creator | Asset | Source parts / scripts | AXZF parts | Radius | 5 s speed | After 4 s brake | Steering change |
|---|---|---:|---:|---:|---:|---:|---:|
| A-Chassis Sedan / Atomicatfo | [4529389736](https://create.roblox.com/store/asset/4529389736) | 117 / 12 | 118 | 1.300 | 180.26 | 0.080 | 60.59° |
| Police Sedan (A-Chassis) / Ravenhasabird57 | [5933886177](https://create.roblox.com/store/asset/5933886177) | 88 / 64 | 87 | 1.400 | 170.17 | 0.113 | 42.42° |
| SUV (A-Chassis) (REMODEL) / sky031208 | [9857510493](https://create.roblox.com/store/asset/9857510493) | 78 / 13 | 77 | 1.050 | 179.92 | 0.097 | 95.95° |
| Original imported Car / Roblox Resources | [14215126016](https://create.roblox.com/store/asset/14215126016) | 75 / 14 | 47 | 1.500 | 179.81 | 0.072 | 64.72° |

Speeds are studs/s. All four passed uprightness, braking, steering, expired input watchdog, reversible cleanup and rebind. These are synthetic server-intent trials, not comparisons against the legacy chassis's handling. Default RWD was used for the three migrated cars; the first import uses FWD/TorqueScale 5. No old HP, suspension, key bindings or plugins are silently translated.

## Stationary vibration

JitterTest warms for 3 seconds, then takes 180 PostSimulation samples. Thresholds were set before these runs: vertical height range <0.02 studs; RMS vertical speed <0.1 studs/s; RMS angular speed <0.1 rad/s.

| Rig | Height range (studs) | RMS vertical speed | RMS angular speed | Result |
|---|---:|---:|---:|---|
| Original prototype | 0 | 0.00000559 | 0 | PASS |
| A-Chassis sedan → AXZF | 0.00000858 | 0.00003012 | 0.07243 | PASS |
| Police sedan → AXZF | 0.00000095 | 0.00000472 | 0.02761 | PASS |
| SUV → AXZF | 0.00000942 | 0.00003473 | 0.06290 | PASS |
| Original imported car | 0 | 0.00000216 | 0.02978 | PASS |

A same-scene 120-sample before/after check on the original imported car reduced angular RMS from **1.96966 to 0.02970 rad/s** (about 98.5%), vertical RMS from 0.75510 to 0.00000292 studs/s, height range from 0.08276 to 0. The later 180-sample lab run above is a separate confirmation; do not mix those sample sets.

The fix uses one pre-step contact snapshot, a coupled implicit spring solver and persistent world-space VectorForce/Torque. This avoids wheel-order feedback and one-frame support impulse bursts. It does not guarantee zero motion on every art rig, slope, curb, moving platform or frame rate.

## Security and limits

All three generated rigs passed Doctor with zero errors and zero retained legacy code containers. The only ModuleScript in each car is the new commented AXZF Tune. The editor fixture also passed source preservation, unknown wheel rejection and ambiguous-model rejection. The conversion removed 96 / 127 / 25 non-art descendants respectively.

Their legacy layouts were A-Chassis 6.81T/older model conventions. **A modern v1.7.2 model was not tested.** Models with other wheel names, mirrored axes, no wheel PrimaryPart, multiple nested cars, unusual wheel topology or wheel animation/plugins may need manual adaptation. Check visual wheel radius and mounts after migration. Four identical radii are assumed.

External art remains local and is excluded from public MIT packages. The police model's listing requests credit; retain Ravenhasabird57 credit if using it. Listing provenance is not proof of broader redistribution rights. See [assets](ASSETS.md), [migration](MIGRATION.md) and [raw results](../evidence/v2-studio-results.json).

## 0.3 follow-up

The same four sanitized external source cars now carry the full49-field commented Tune template. Their stationary-jitter regression passed with the new stability defaults (evidence/v3-jitter-regression.json). The original imported FWD car and prototype also ran paired left/right55/90stud/s occupied-mass turn trials: worst roll8.409→0.457° and10.329→0.879°. This version's turn comparison does not extend that result to every migrated model. Source art remains outside Git and legacy code was not executed. The public kit retains the expanded template through PrototypeCar, CreatorCarAdapter and Migration.convert.
