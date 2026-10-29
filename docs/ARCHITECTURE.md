# A-XZF-Tune architecture / design contract

Independent four-contact raycast vehicle, authored from scratch. Reference review: A-Chassis README and v1.7.2 release notes, 2026-10-29. No upstream implementation or Tune schema imported. Release target: production-quality open-source kit; current certification is governed by TESTING.md, not by this design goal.

## Contract
Model has Chassis (BasePart, forward = local -Z), DriveSeat (VehicleSeat), Body (Folder/Model), Wheels (Folder/Model with FL/FR/RL/RR, each a BasePart or Model with PrimaryPart), and four Chassis Attachments named FL/FR/RL/RR. Attachment positions are spring tops; wheel centers at full extension are top - up * RestLength. Wheels are cosmetic, individually articulated with Motor6D and welded subparts. Chassis is the only colliding mass. The kit never needs an opaque single-body mesh.

Model adapter is opt-in and mutates only the supplied model. It accepts explicit wheel references; no name guessing during runtime. Doctor reports errors before binding. Bind is transactional, snapshots changed properties, and destroy restores the source rig. Unsupported scripts/constraints are rejected, not executed. Users remove their previous chassis before adapting.

## State and authority
Unbound → Bound/Parked → Driven → Parked → Destroyed. Bind fails before mutating invalid rigs. Seat occupant change clears command, sequence, and watchdog. Only occupant's Player may issue commands. Dead/removed occupants stop driving. Disconnect uses the seat watchdog; model removal tears down registration. Model creation after startup supported by tag events. Idempotent destroy disconnects, destroys owned instances, restores properties. No persistence, purchases, analytics, HTTP or dynamic asset requires in runtime.

One server PreSimulation dispatcher. Four rays per vehicle/frame. Parked stable vehicles reduce visual work after a grace period; contact solving remains active to support gravity. No task per wheel. Physics impulses use dt capped to 1/30; no catch-up impulses at a stale position. This intentionally trades slow-frame accuracy for bounded stability. Server owns the assembly; latency and server scaling must be measured before large deployment. No claim of competitive predictive netcode.

## Equations (Roblox units)
For each wheel: cornerMass = assemblyMass/4; spring k = cornerMass*(2*pi*FrequencyHz)^2; damping c = 2*DampingRatio*sqrt(k*cornerMass). Normal load = clamp(k*(RestLength-length)-c*normalVelocity,0,cornerMass*g*MaxLoad). Length = max(0, rayDistance-radius). Upward contact normal must dot chassis up > 0.25. No ray hit = zero tire/suspension force. Equilibrium sag = g/(2*pi*f)^2; travel must exceed sag. Mass and gravity are read from engine.

Tire lateral demand = -lateralVelocity*cornerMass*LateralResponse. Brake demand opposes forward velocity and is capped by mass*abs(velocity)/dt to avoid reversing at rest. Combined longitudinal/lateral demand is projected onto friction circle mu*normalLoad. Surface Grip attribute (0.05..3) multiplies configured grip. Rolling resistance and aerodynamic drag dissipate energy. No artificial force while airborne. Handbrake acts on rear contacts. Ackermann inner/outer angle derives wheelbase/track; positive command turns right, speed-sensitive steering and exponential smoothing are dt-based.

Powertrain: signed accelerator [-1,1]; opposing direction first brakes until speed < 2 studs/s; automatic forward gears and reverse. Gear changes have cooldown and RPM hysteresis. Engine RPM derives wheel road speed/radius * gear * final drive with idle/redline bounds; torque curve is piecewise-linear. Torque*ratio/radius becomes wheel force distributed by FWD/RWD/AWD. This is a road-speed coupled drivetrain, not a clutch/wheel-angular-inertia simulator. TCS caps requested forward force by grip; ABS prevents numerical velocity reversal, not a full wheel-slip ABS model. These fidelity limits are explicit.

## Network
Control RemoteEvent: (registered Model, {seq=integer, throttle=number [-1,1], steer=number [-1,1], brake=number [0,1], handbrake=boolean}). Reject extra keys, non-finite/out-of-range values, non-occupants, stale/replayed sequence. Per-player token bucket is checked before model inspection, with no per-attacker vehicle allocation. 30Hz average/45 burst. Watchdog after 0.35 s brakes. New driver resets packet sequence. Telemetry attributes at 10Hz, no per-frame Value instances. No position/velocity accepted from client. Local controls clear on focus loss/chat/seat exit. Studio-only test seam refuses use in live servers.

## Acceptance / experimental contract
One isolated __Prototype_AXZF experiment tests spring feasibility before promoting a separate implementation. Flat plane, 4 mounts, standard gravity, synthetic no-driver control. Pass: 5 s bounded height, upright dot > .9, max vertical speed < 5 after settling; pivot if sag bottoms out, stop on nonfinite/explosive motion. Then production tests: prototype and imported multi-part rig accelerate > 10 studs/s in 5 s, brake to < 3 in 4 s, right steering changes heading > 5 degrees, exit stops propulsion; invalid messages rejected. Track slopes, grip, airborne, teardown, repeated bind and fleet timing measured separately. Do not substitute pure math tests for Studio physics.

## Extension boundary
Public modules: Tune.resolve, Doctor.inspect, Adapter.prepare, Vehicle.new/step/setInput/destroy/getTelemetry, Fleet.start/stop/get, Powertrain.new/step. Server applications may call Vehicle:setInput for NPCs. Event-free polling telemetry avoids forcing a particular HUD or sounds. Config presets and surface Grip attributes need no fork. Future extensions (clutch simulation, differential slip, prediction) are proposals, not shipped features.

Official API evidence checked 2026-10-29: [impulses and network ownership](https://create.roblox.com/docs/reference/engine/classes/BasePart), [PreSimulation](https://create.roblox.com/docs/reference/engine/classes/RunService), [raycasts](https://create.roblox.com/docs/reference/engine/classes/WorldRoot).
