# Verification update — 0.2.0-rc.1

2026-10-29, Europe/Istanbul. The 0.1 record below is historical. Current evidence: [raw results](../evidence/v2-studio-results.json), [migration](../evidence/v2-migration-report.json), [device rectangles](../evidence/v2-ui-measurements.json), [saved scene](../evidence/v2-saved-demo.json), [drag release](../evidence/v2-input-drag-release.json).

| Check | Current result |
|---|---|
| Luau compile / headless / deterministic artifacts | 49 files / 68 cases / PASS |
| Studio unit contracts | 75/75 PASS |
| Three real A-Chassis migrations | Sedan / police / SUV: Doctor, drive, brake, steering, watchdog, cleanup/rebind PASS |
| Original imported car | Drive regression PASS |
| Stationary jitter | Prototype + four external rigs: all below predeclared thresholds; COMPATIBILITY.md |
| Auto-recovery | Inverted recovers; airborne/upright untouched; blocked space waits then recovers; PASS |
| Occupied recovery | Driver stayed seated, one recovery, up dot 0.99992, server ownership retained |
| Fleet lifecycle | Pre-tagged spawn, ancestry return, duplicate add, tag removal/return, repeated stop PASS |
| Handling | Airborne horizontal thrust 0; grip differentiation, handbrake 0.0415, reverse -43.48, 8° slope PASS |
| Two actual clients | Ownership, cross-driver denial, malformed rejection, valid drive, replay stop, exit PASS |
| 12-car Lua solve | 302 samples: mean 0.781 ms, p95 1.109 ms, max 3.240 ms; 48 rays/frame |
| Circular HUD | Native seat HUD hidden; H hides help; real telemetry; approved design imported |
| Simulated mobile UI | iPhone 7/13 landscape, iPhone 13 portrait, iPad 6 landscape: no button/dial overlaps, min 48 px targets |
| Input actions | GO, PARK, KEYS, EXIT exercised; Tune Handbrake=P worked; drag-off release changed intent throttle 1→0 |
| Exit restoration | Custom HUD off, seat exited, native TouchGui restored |
| VFX | Four held moments, uploaded textures, live client burst, no preview-address leftovers |

Full phone multitouch and physical gamepad are unverified. Script timing is not total physics/GPU/network/memory profiling. Latency/loss/streaming, long soak, full reset/reconnect matrix and Roblox-aware strict analysis remain gates in READINESS.md.

Reproduce the new checks in Studio Server:
```lua
local t=game.ServerStorage.AXZFTests
require(t.RunUnitTest)()
require(t.RecoveryTest)()
local m=game.ServerStorage.AXZFCompatibilitySources.AXZF_AC_Sedan
require(t.DriveTest)(m,require(m.Tune))
require(t.JitterTest)(m,require(m.Tune))
```
For MigrationTest stop Play and run require(game.ServerStorage.AXZFTests.MigrationTest)() in Edit. CompatibilitySources requires separately acquired reviewed art; it is only in the author's ignored local scene, not public packages.

Defects found during this update: sequential/per-frame support impulse jitter; cold assembly binding during parent signals (queued one engine heartbeat, guarded concurrent binds); device-switch layout/native TouchGui races; drag-off held inputs. All were repaired and relevant checks rerun.

Test-fixture corrections: recovery needed its own floor outside the small demo track. The faster drive trial initially ran off the finite track; it now has a separate 2,000-stud lane (below engine part-size limits), with unchanged pass thresholds. Those failed setup runs were not recorded as driving passes.

Local export corrections: old rbxmk XML cannot read current NetAsset payloads; native binary preserves geometry. Service descriptors are required when encoding a place. Current native PhysicalProperties decoding was also incompatible; local exported cars use explicit authored mass in Tune and omit that corrupt root payload. The public migration/factory still creates the root normally. These are packaging fixes, not evidence that all arbitrary binary converters or user rigs are supported.

---

# Verification record — 2026-10-29

Candidate: 0.1.0-rc.1, from this repository's source/packages. Original Studio: A-XZF-Tune, placeId 72435697524161, universe 10773638854. Synthetic development tests, no persistent state or publishing. One desktop client for keyboard/device checks; a separate StudioTestService session launched **two actual client DataModels** for the multiplayer checks. Phone/tablet are Studio simulation, not physical hardware.

Published source revision `f870ffc`: [remote Validate run passed](https://github.com/yagizxzf/A-XZF-Tune/actions/runs/40874968917). Later delivery-record changes do not alter the tested vehicle solver.

Raw attributable tool results: [evidence/studio-results.json](../evidence/studio-results.json). UI evidence: [phone](../evidence/phone-landscape.png) and [tablet with explicit exit](../evidence/tablet-landscape.png). Phone image precedes the final addition of Exit/hiding default character controls; tablet image shows that final layout. Do not interpret the earlier screenshot as the final seven-button surface.

## Results

| Check | Observed result | Status |
|---|---|---|
| Isolated spring experiment | 301 samples/5 s, upright=1, height=1.849, settled max vertical speed=0.818 (<5) | PASS / PROCEED |
| Luau 0.744 compilation | 28 source/example/test files, no parse/compile failures | PASS |
| Headless shared contracts | 58 run, 58 passed | PASS |
| Studio units | 65 run, 65 passed; latest lifecycle checks also passed | PASS |
| Original multi-part car | 5 s acceleration 145.01 studs/s; after 4 s braking 1.227; steering trial 78.2° | PASS |
| External 47-part car | 5 s acceleration 133.91; after braking 0.237; steering trial 34.86° | PASS |
| Both drive rigs | Upright >.99, watchdog expires after .5 s, cleanup restores anchored parts, destroy twice/rebind succeeds | PASS |
| Airborne throttle | Horizontal speed 0 with no contact | PASS |
| Surface Grip | 1 s run: normal 77.15 vs low-grip 17.41 studs/s | PASS |
| Rear handbrake | 0.264 studs/s after stopping trial | PASS |
| Reverse | Signed road speed -43.59 studs/s | PASS |
| 8° slope | Upright .988, speed .585 while braking | PASS |
| Real keyboard client | W produced 73.27 studs/s; B reduced to .00074 in 3 s | PASS |
| Textbox focus regression | W while focused left only 1.225 vertical spring jitter; after release W produced 70.27 studs/s | PASS |
| Single-client hostile packets | 20 invalid own-driver + 20 non-driver intents produced no drive movement; valid control produced 76.99 studs/s | PASS |
| Two-client multiplayer | Both occupied; server owns both; cross-driver denied; malformed denied; valid drives; replay expires to stop; exit clears seat | PASS |
| Fleet lifecycle | Pre-tagged spawn, duplicate add, remove/return, untag/retag, repeated stop | PASS |
| 12-car benchmark | 301 samples; mean .739 ms, p95 1.070 ms, max 1.569 ms; 48 rays/step | PASS (measurement only) |
| Independent public demo | New Studio opened generated .rbxlx; car/track/spawn initialized; 65 units passed again | PASS |
| Phone simulation | iPhone 17 Pro landscape, viewport 750×381; native button-container overlap fixed; 64×64 controls, separated layout | PASS for inspected layout |
| Tablet simulation | iPad Pro M5 13in landscape; default movement UI overlap removed; seven controls visible; exit restores native UI/removes custom controls | PASS for inspected layout/exit |

Speed measurements use total assembly speed, and tests use synthetic repeated server intent. A driving pass is not a subjective handling review, real-car calibration or race-grade simulation claim. No performance threshold was invented after measuring. Fleet timing is the Lua solver block only, including initial settling and parked cars, on this machine; it excludes network, engine physics, rendering, allocation/GC attribution and hardware variation.

## Reproduction

Build and check commands are in README. Headless execution uses the **same four shared test modules**, translating only engine require paths into temporary relative CLI paths. It does not emulate physics or replace expected values. Temporary files are removed after execution. `tools/check.py` also compares generated package bytes with the committed artifacts.

For Studio, open the demo, start Play and run on Server:

```lua
require(game.ServerStorage.AXZFTests.RunUnitTest)()
require(game.ServerStorage.AXZFTests.FleetTest)()
require(game.ServerStorage.AXZFTests.HandlingTest)()
require(game.ServerStorage.AXZFTests.FleetBenchmark)(12)
local source = require(game.ServerStorage.AXZFExamples.PrototypeCar).create()
local report = require(game.ServerStorage.AXZFTests.DriveTest)(source, nil)
source:Destroy()
print(game:GetService("HttpService"):JSONEncode(report))
```

For the imported model, keep an **unbound, untagged** source under ServerStorage, then pass it to DriveTest with `{Radius=1.5, Drive="FWD", TorqueScale=5}`. The harness disables seats on its clone, preventing a human from contaminating the synthetic trial. It cleans up even on an assertion/error.

Stop Play before the two-client test. From an Edit/plugin/Command Bar context:

```lua
local result = game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2, {name="AXZF"})
print(game:GetService("HttpService"):JSONEncode(result))
```

The test-only scripts recognize that explicit argument, create an isolated remote and cars, run the test, clean up and call EndTest. In ordinary Play/live servers they perform no test actions. The multiplayer session also has a 45-second watchdog. [Official API](https://create.roblox.com/docs/reference/engine/classes/StudioTestService).

## Defects found and corrected

- Doctor initially missed WeldConstraint because it is separate from the expected constraint ancestry. Initial unit run was **64/65**, not a pass. Added explicit class detection; original expectation retained; later runs 65/65.
- An automatically seated character left SeatWeld in the first synthetic drive clone. Isolated test clones now disable seats. Runtime destroy explicitly unseats/removes its seat weld and restores network ownership.
- Original factory wheel orientation turned cylinders onto their sides; corrected wheel axle orientation. Cleared Edit require caching by recreating from a fresh factory copy; Play tests use a fresh VM.
- ContextActionService's default button container clamped/overlapped custom positions. Native buttons now live in a full safe-area frame at 64px. Tablet character joystick/jump overlap removed while seated, with explicit Exit and native UI restoration.
- Third-party texture permissions/type mismatches: geometry-only adapter removes those dependencies. Original package never executed and was discarded after inspection.
- An early compiler invocation treated `null` as an input filename. This was a command failure, not 23 Luau source failures. Corrected to `--null`; dedicated check tool now runs the proper invocation.
- Early direct test-registry reads from the assistant context returned nil despite the game's running fleet; removed that unused registry and verified actual inputs through engine state/real remotes instead.

## Environment observations / limits

Existing Studio plugins emitted `Roundy`/`Animation Spoofer` errors and large diagnostic lists; they are outside this kit and remain unchanged. Console review did not establish a globally clean Studio plugin environment. The original external package emitted texture failures; the sanitized rig has no retained texture/SurfaceAppearance dependencies. Avatar content can still emit unrelated asset loading errors.

Not yet verified: physical phone/tablet/gamepad operation, portrait layout, adverse network latency/loss, reconnect and character-reset matrix, hours-long soak, total engine/network/memory budgets, full strict static analysis with Roblox type definitions, Rojo build, arbitrary user-art rigs and streaming boundary behavior. These are tracked in READINESS.md/ROADMAP.md, not marked passed.

All tool-started Play sessions ended. Device simulator returned to landscape/default viewport. Temporary experiment/drive/handling/benchmark cars and remotes were removed; intentionally retained are the two evaluation cars and test track, plus an inert imported source copy in the author's Studio. No production persistence, purchases, analytics or publishing were used.

Final disk verification: the rebuilt build/A-XZF-CompatibilityDemo.rbxl was independently reopened, four source rigs passed Doctor with exact dimensions/45 MeshParts/31 unions and explicit Tune mass, then all five vehicles bound upright at stable heights and75 units passed. Server Workspace playing emitters0 and preview leftovers empty. See evidence/v2-delivery-file.json.

Final cancellation regression: DelayedTune fixture exercises remove/re-add while configuration is loading; pendingCancelRebind and all lifecycle flags passed. Latest source compiles49 Luau files;68 headless and75 Studio units pass. Raw: evidence/v2-final-regression.json.

Cross-platform packaging correction: the first 0.2 remote run compiled49 files and passed68 cases but failed byte reproducibility. Windows Path ordering differed from Linux for VFXService/Vehicle. tools/build.py now sorts filename strings explicitly; regenerated packages pass local checks. Final successful remote run is recorded in HANDOVER.md after verification.
