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

Build and check commands are in README. Headless execution uses the **same eight shared test modules**, translating only engine require paths into temporary relative CLI paths. It does not emulate physics or replace expected values. Temporary files are removed after execution. `tools/check.py` also compares generated package bytes with the committed artifacts.

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

## 0.3 validation

2026-10-29: 56 Luau files compiled, 83 headless and 90 Studio units passed. Both the lab and the actual original place72435697524161 ran the 90-unit suite. Compile is syntax validation, not a Roblox-aware type analysis.

| Check | Observed result |
|---|---|
| Occupied-mass import turn, 55/90 stud/s entries, both directions | peak body roll 8.409° before → 0.457° after |
| Same prototype turn | peak body roll 10.329° before → 0.879° after |
| Parking while commanding full throttle | Stopping → Parked; 0.0552 stud/s, no anchoring, HB false |
| Parking request after input clear | retained; second request false accelerates to81.51 stud/s in1s |
| Parking on8° slope | 0.0589 stud/s after low-speed gravity compensation; threshold<0.1 |
| Actual main P/W/P/E input | parked0.0034 stud/s despite W; release48.36; exit keeps P |
| Optional ParkOnSpawn / AutoParkOnExit | both true after actual human entry/exit |
| Actual per-car configuration | prototype and import each expose49 top-level fields; import Radius1.5/FWD/TorqueScale5 preserved |
| TuneEditor custom values | AWD, Power1.7, Radius1.8, ParkO, custom curve and tutorial preserved |
| Imported-car stationary jitter | all four sources pass: angular RMS0.00260/0.03209/0.04892/0.00310rad/s; height range0 |
| Existing handling regression | airborne horizontal speed0, Grip response, handbrake, reverse and8° service-brake slope pass |
| Mobile icon controls | all9 images loaded; gas/brake/steer/reverse/handbrake/park/help/exit and drag-out release pass |
| Device layout | iPhone7/13 and iPadA16 landscape; no overlap; smallest hit84.5×58.5logical px |
| Main original HUD | single cockpit, P/PARK ON and HB ON independently; native seat HUD false |

RollTest uses a deterministic24-Roblox-mass seated-rider surrogate after binding. For each vehicle, it settles2s, starts at55 or90stud/s, then holds throttle0.35/steer±0.65 for2.5s, sampling PostSimulation. Predeclared thresholds: roll<12°, yaw>5° and final up.Y>0.9; all8 revised trials pass. Before/after peak reduction is>90%; peak speed/yaw differ modestly due to changed contact response. This is a measured flat-road handling comparison, not a claim of real-car accuracy, zero roll under every load, or no rollover at arbitrary speed.

Reproduce using **unbound** source models:

```lua
local model = game.ServerStorage.AXZFCompatibilitySources.AXZF_ImportedCar
local tune = require(model.Tune) -- only our authored AXZF Tune
print(game:GetService("HttpService"):JSONEncode(require(game.ServerStorage.AXZFTests.RollTest)(model,tune)))
print(game:GetService("HttpService"):JSONEncode(require(game.ServerStorage.AXZFTests.ParkingTest)(model,tune)))
```

Evidence: evidence/v3-*.json and ui/shots/v3-studio-*.png. Initial v3-roll-before.json contains a failed bound-prototype-clone attempt; corrected baseline uses a fresh factory model in v3-roll-before-prototype.json. The first optional exit test failed its seating setup; v3-autopark-retest.json unseats/repositions the human first and passes. No failures are counted as passes. The earlier0.4065stud/s parking slope observation is superseded by v3-parking-static-hold.json after gravity compensation.

Physical multitouch/gamepad, new0.3 two-client park/adverse-network tests and portrait0.3 are not claimed. Existing two-client authority checks are historical0.2 results; the same ownership gates remain and park type/legacy-packet checks now run headlessly. The tested place is LandscapeSensor. All started Play sessions and device simulation were stopped after testing.

## 0.4 validation

61 Luau compile (59 packaged scripts plus2 diagnostic probes),93 headless and100 Studio units pass. Main original Studio and local five-car demo both ran100/100. Ten new deterministic cases cover direction, radius scaling, idle, lock, circumference, dt independence, RPM conversion, hitch duration and inner/outer speed differences.

The old server implementation measured+0.266667rad for10stud/s, Radius1.25, raw dt0.1, where rolling requires-0.8rad: wrong sign plus the1/30 physics dt cap affected visual rotation. Client Transform now rolls in the correct direction using full visual dt. Live forward/reverse/import traces pass paired frame checks; max angular-rate error0.000297rad/s, max joint pose error0.000691rad. Main import at mean31.66stud/s showed200.67wheelRPM, with selected engine/gear RPM separate. A measurement waiter sees the previous visual update, so the corrected probe pairs it with the previous dt/speed; the first mismatched-frame probe failure remains recorded.

Moving handbrake check at64.08stud/s: rear Transform delta0, front0.2227rad over0.1s. Idle:850engineRPM, wheel delta0 over0.3s, speed0.0023. Initial handbrake attempts had invalid preconditions (the unattended test car left the finite track; another was already stopped); the explicit moving retest passes. These are not counted as successful earlier tests.

All mobile actions send correct intents; P toggles, gas=1, brake=1, steering=-1/+1, R throttle=-1, HB separate. Drag-out release clears held input. Help stays separate; unloaded-image fallback works; exit disables cockpit and restores TouchGui. Five images load on iPhone7/13/iPadA16 landscape with no overlap. The top-bar utility hit issue was reproduced and corrected by moving the group down.

Import DriveTest and FleetTest passed, with4 baseline tagged motors remaining after temporary rigs were destroyed. Four imported rigs pass180-sample jitter: angular RMS sedan0.00261, police0.03656, SUV0.05084, import0.00316rad/s; height range0. Five-car delivery has20 tagged motors, all rigs upright/bound and100 units passed. Active main P/E and WheelVisuals presence passed.

Evidence: evidence/v4-*.json, ui/shots/v4-studio-*.png. Rendering/layout and input were simulated; physical multitouch/gamepad, adverse network, total FPS/memory profiling and0.4 portrait are not claimed. Public packages and local native demo were regenerated; this session validated the already-open demo after updating its sources, without reopening the new binary in another window.

Live client probes used for0.4 are saved as tools/visual-probes/Wheels.luau and Cockpit.luau. Execute their saved text in a Studio **Client** context after seating in AXZF_Prototype; wheel probe expects an already-moving car. For the imported main car, change that model path to AXZF_ImportedCar. They return JSON, do not inject driving input, and reject live/server contexts. Their syntax is included in the61-file check; public packages contain59 scripts.
