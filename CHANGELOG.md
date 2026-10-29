# Changelog

## 0.4.0-rc.1 — 2026-10-29

- Approved original physical pedal/handbrake art, then user-requested matching left/right keys; four mobile control groups replace the icon grid.
- Critical image preload, native loading fallback and safe utility placement below the Roblox top bar.
- Correct forward/reverse wheel spin, full visual dt, client Motor6D.Transform animation and imported-hub axes; rear handbrake/park locks.
- Shared road-speed RPM helper reused by Powertrain; no physics force or ownership moves to the client.
- 61 compile/93 headless/100 Studio tests; live forward/reverse/import/idle/handbrake, mobile input, drive/fleet and four-car jitter regressions.

## 0.3.0-rc.1 — 2026-10-29

- Separate P parking mode, all-wheel braking, low-speed slope hold, persistent request and P/HB telemetry.
- Complete 49-field Turkish Tune tutorial installed in the actual original cars; Edit-only preservation-aware TuneEditor.
- Approved Lucide image buttons for mobile driving, park/handbrake/exit/help, press feedback and small-phone layout fix.
- Adjustable tyre roll lever, bounded axle anti-roll and grounded roll damping; measured occupied-mass turn comparison.
- 56 Luau compile, 83 headless and 90 Studio unit checks; park, touch input and imported-car jitter regressions.

## 0.2.0-rc.2 — GUI startup hotfix

- Default Fleet.start now creates the cockpit for both standard and custom bootstraps.
- Driver waits for replicated UI dependencies and reports missing packages/template.
- Command Bar installer reuses protected containers and synchronizes open editor buffers.
- Applied to the actual original Studio; seat entry, H, E, second car and respawn regression passed.

## 0.2.0-rc.1 — 2026-10-29

- Coupled implicit suspension and persistent force/torque support reduce imported-car jitter.
- Ground/clearance-aware auto-recovery, including occupied and obstructed cases.
- Approved circular cockpit, configurable/hideable key help, separate mobile controls, parking toggle and exit.
- Commented per-car Tune: power/speed/mass/suspension/recovery/VFX/display and keyboard bindings.
- Editor-only geometry migration with one-call selection workflow; three real A-Chassis cars validated.
- Client-only tire smoke/dust using original textures and bounded nearby events.
- New suspension/config/editor/recovery/jitter tests; 49 compile, 68 headless, 75 Studio units.
- Spawn binding race fixed; local external-art scene kept outside Git. Stable v1.0 gates remain open.


## 0.1.0-rc.1 — 2026-10-29

- First independent implementation: four-ray suspension/contact solver, combined tire grip, automatic forward/reverse, Ackermann steering, four presets and surface Grip.
- Explicit multi-part rig contract, editor adapter, setup Doctor and reversible binding.
- Server-owned fleet, driver authorization, packet bounds/replay/rate validation and timeout brakes.
- Keyboard, gamepad bindings and safe-area touch driving/Exit controls.
- Original multi-part car and track; geometry-only recipe for a separately obtained Creator Store car.
- Headless/Studio unit, drive, handling, fleet, multiplayer harnesses; deterministic packages and CI.
- Initial measured evidence and release-readiness concerns documented. This is not a stable v1.0 certification.
