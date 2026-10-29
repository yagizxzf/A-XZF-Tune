# Release readiness — 0.2.0-rc.1

Audit: 2026-10-29, Europe/Istanbul. Scope is an open-source vehicle kit and evaluation scene, not the launch of a complete game. Runtime/source are independently authored. The owner's GitHub repository is yagizxzf/A-XZF-Tune. Reference live place: 72435697524161. See [test evidence](TESTING.md).

**Verdict: evaluation candidate ready; stable production certification remains CONDITIONAL.** This document does not represent the outstanding conditions as accepted by the user. A public source delivery is distinct from publishing a game or declaring a stable release.

| Domain | Status | Evidence / remaining condition |
|---|---|---|
| Source/build | PASS | Original modules, reproducible Python XML packages, fresh Studio demo boot |
| Automated contracts | PASS | 68 headless + 75 Studio units; parse/compile checks |
| Critical driving | PASS | Original and external multi-part rigs: accelerate/brake/steer/watchdog/rebind |
| Driver authority | PASS within tested scope | Real two-client cross-driver/malformed/replay/valid tests; server ownership |
| Lifecycle | PASS within tested scope | Tag, ancestry, duplicate add, repeated cleanup; occupied exit |
| Handling | PASS within tested scope | Airborne no thrust, Grip response, handbrake, reverse, 8° slope |
| Touch UI | PASS for simulator sample | iPhone/iPad landscape plus iPhone portrait; circular HUD/buttons/native-control restoration |
| Client/device adoption | CONCERN | Actual gamepad/physical touch and full focus/death/reset/reconnect matrix need tests |
| Performance | CONCERN | 12-car Lua solve measured; no total frame/network/GPU/memory/device budget or long soak |
| Replication quality | NOT CHECKED | Latency/loss, many players, streaming boundaries; server-authority latency tradeoff |
| Static typing | NOT CHECKED | Compilation is not Roblox-aware strict type analysis; no full analyzer claim |
| Art portability | CONCERN | Original example MIT; external car tested, provenance recorded, no MIT redistribution |
| Persistence/economy/payments | NOT APPLICABLE | None implemented or touched |
| Analytics/privacy | NOT APPLICABLE for stored data | No telemetry upload, identity log, datastore or analytics service; transient driver state only |
| Publishing/Creator Dashboard | NOT CHECKED | No live place publish; two original VFX images uploaded; destination experience permissions still require adoption checks |
| Runtime error environment | CONCERN | Kit checks passed; pre-existing external Studio plugins emit unrelated errors |
| Rollback | PASS for source/model scope | Stop fleet/remove tags; restore prior runtime and model revision; no data migration |

## Stable-release conditions

Before claiming v1.0 production readiness: run adverse latency and streaming tests, physical input/device checks, repeated death/reset/reconnect, a risk-appropriate long session with memory/network profiling, Roblox-aware type analysis, and representative user-built rigs. Set the adopting game's actual performance budget before pass/fail comparison. Assign owners and explicitly accept any remaining risks; none is silently accepted here.

Four-ray tire contact, road-speed RPM, lack of clutch/differential/wheel inertia, no prediction and runtime wheel-joint replication are deliberate current limits. Apps needing those should retain their existing solution or extend this backend and rerun the relevant gates.

## Operations

Keep previous package and vehicle geometry in version control. Unregister the fleet for a local kill switch, then roll back the whole source/model revision. Bind-time errors are visible on AXZFError. Diagnose one minimal rig first; do not hot-patch mystery Toolbox scripts or grant network ownership to clients as an unexplained fix. No production database repair, monetization config or external dashboard rollout is required by the kit itself.
