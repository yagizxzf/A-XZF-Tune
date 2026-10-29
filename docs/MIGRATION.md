# Evaluating a move from A-Chassis

Reference reviewed 2026-10-29: A-Chassis README and [v1.7.2-stable release notes](https://github.com/lisphm/A-Chassis/releases/tag/v1.7.2-stable). No upstream implementation or model was imported. This is a different backend and configuration contract; equivalent settings do not imply equivalent handling.

| Existing concern | A-XZF approach |
|---|---|
| Attach a chassis to custom art | Explicit body/seat/root/wheel hub/mount contract and geometry adapter |
| Diagnose broken installation | Doctor codes and AXZFError before/after bind |
| Own and clean spawned vehicles | Fleet tag/ancestry lifecycle with idempotent cleanup |
| Tune suspension for another mass | Frequency/damping-derived corner forces using actual assembly mass |
| Tune for a surface | Part Grip attribute times tire Grip |
| Verify a change | Shared contract tests + Studio driving/handling/multiplayer harnesses |
| Limit client physics authority | Server-owned assembly; occupant-authorized intention packets |
| Add a custom HUD/audio | Bounded-rate telemetry attributes and server API |

## Procedure

1. Duplicate your working car/place. Keep the original working revision available for rollback.
2. Preserve art only. Remove the old chassis's scripts, remotes, constraints, joints, force instances and configuration. Never run both chassis on the same assembly.
3. Identify actual individual wheel models and hubs. Normalize root axes and follow MODEL-INTEGRATION.md. Start with a new Tune using project defaults; there is no automatic A-Chassis Tune translation.
4. Confirm dimensions/radius/mounts and static suspension before torque tuning. Previous unit conventions may differ; do not paste numbers assuming the same units.
5. Port your integration code to the API. Old plugin events/values are not supported. Replace references with AXZF telemetry or your server's Vehicle handle.
6. Run your part-built baseline, adapted art, occupied handling, latency, concurrent drivers and device tests. Compare measured behavior, not only top speed.
7. Roll out on a test place, then a limited audience after your own release review. Restore the original model/runtime revision if behavior or performance regresses.

## Tradeoffs

Server physics centralizes authority and adds server work and input latency. Four rays are predictable and simple but do not model tire volume/curbs, wheel angular momentum, clutch slip or a physical differential. The automatic powertrain and rear handbrake prioritize a small understandable surface. Keep your existing solution if its advanced features are required and not present here. This release does not claim drop-in parity, a migration speedup, or better device/network performance without project-specific evidence.
