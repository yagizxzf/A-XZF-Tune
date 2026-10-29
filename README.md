# A-XZF-Tune

An independently authored, modular Roblox vehicle kit. MIT licensed. **0.2.0 release candidate** — working source and Studio evidence are included; see the [readiness record](docs/READINESS.md) before adopting it in a live experience.

[Türkçe](README.tr.md) · [Quick start](docs/INSTALLATION.md) · [Bring your own car](docs/MODEL-INTEGRATION.md) · [Tune reference](docs/TUNING.md) · [API](docs/API.md) · [Tests](docs/TESTING.md)

## Why evaluate it?

- **Model-independent rig:** explicit four-wheel attachments, separate body panels and wheel models. A wheel may contain several meshes; no single-mesh vehicle requirement.
- **Doctor before binding:** actionable error codes for missing mounts, incorrect wheel layout, old scripts and leftover constraints.
- **Reversible binding:** owned joints are tracked; removing the vehicle/tag restores geometry properties and stops its simulation. Duplicate registration is harmless.
- **Server-owned physics:** clients send bounded driving intentions, with occupant checks, sequence/replay checks, token-bucket rate limits and a dead-input brake watchdog.
- **Inspectable handling:** mass-derived spring/damper rates, combined tire friction circle, surface Grip attributes, Ackermann steering, speed-sensitive steering, automatic forward/reverse drivetrain and four presets.
- **Tests you can run:** 68 headless shared contract cases, 75 Studio unit cases, driving/handling/lifecycle harnesses, a two-client abuse test, fleet solve benchmark and reproducible XML packages.
- **Native controls:** keyboard, analog gamepad bindings and safe-area touch buttons with an explicit Exit action. Touch controls restore the character controls after leaving.

These are reasons to evaluate this implementation, not a claim that every competing chassis lacks them. There is no compatibility shim for A-Chassis plugins or Tune tables.

## Try it

Open [build/A-XZF-Tune-Demo.rbxlx](build/A-XZF-Tune-Demo.rbxlx) in Roblox Studio and press Play. Walk into the orange car's driver seat. W/S drive/reverse, A/D steer, B brake, Space handbrake, E exit. The example is built from editable parts, not an opaque mesh.

For an existing place, insert [build/A-XZF-Tune.rbxmx](build/A-XZF-Tune.rbxmx) and move each service folder's children to the corresponding Roblox service. Follow [installation](docs/INSTALLATION.md) to avoid duplicate bootstraps.

```sh
python tools/build.py
# With the pinned Luau executables installed locally:
python tools/check.py --compiler .tools/luau/luau-compile --runtime .tools/luau/luau
```

No Python packages, runtime HTTP, Wally dependencies, paid assets or dynamic asset requires are needed. A Rojo project is supplied as an optional workflow.

## Evidence and limits

On 2026-10-29, the original prototype and four sanitized external rigs passed the current Studio checks. Three were actual A-Chassis migrations; their drive and jitter results are in the compatibility matrix. Two actual clients passed cross-driver/malformed/replay/valid/exit checks. Twelve vehicles took 0.781 ms mean / 1.109 ms p95 script solve time on the test machine; this excludes total engine/network/GPU cost. [Results and reproduction](docs/TESTING.md).

The external car is tested in the author's local scene and has a reproducible [geometry adapter](examples/CreatorCarAdapter.luau). Its art is **not included under the MIT license or redistributed in this repository**. Obtain it separately from its [Creator Store page](https://create.roblox.com/store/asset/14215126016); see [asset provenance](docs/ASSETS.md).

Current fidelity: raycast contact tires, road-speed coupled automatic drivetrain. No clutch, individual wheel angular inertia, predictive client physics, damage, engine audio or A-Chassis plugin compatibility. Four contact rays can miss sharp curbs. Large latency, real device performance and long-session adoption testing remain release gates. A release candidate is not a universal production certification.

## Independent implementation

This is not a fork, rename or code port of [A-Chassis](https://github.com/lisphm/A-Chassis). Its README and v1.7.2-stable release notes were used to understand the current reference; upstream chassis implementation was not copied. Three legacy car packages were quarantined for geometry migration tests; their executable code was never run. See [design and provenance](docs/ARCHITECTURE.md) and [migration](docs/MIGRATION.md).

Contributions: [CONTRIBUTING.md](CONTRIBUTING.md). Security reports: [SECURITY.md](SECURITY.md). License: [MIT](LICENSE), covering authored kit code and original examples only.

## 0.2 evaluation update

Circular speed/RPM cockpit, hideable/remappable key help, separate mobile controls, automatic safe-space recovery, coupled implicit suspension, client-only tire smoke/dust and a commented per-car Tune are included. The editor migration helper converts selected legacy geometry in one call. Three real A-Chassis vehicles passed drive and stationary-jitter tests: [compatibility matrix](docs/COMPATIBILITY.md), [migration](docs/MIGRATION.md), [HUD](docs/HUD.md), [VFX](docs/VFX.md). The latest 12-car script measurement is 0.781 ms mean / 1.109 ms p95.
