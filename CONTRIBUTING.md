# Contributing

Start with README and docs/ARCHITECTURE.md. Development continuity lives in MARKDOWNS/AGENTS.md → HANDOVER.md → ROADMAP.md → latest PROGRESSION.md. Keep changes scoped and record actual test results. Use one source of truth in src/, not hand-edited Studio-only changes.

1. Describe the observable bug/behavior, environment and a minimal reproducible rig.
2. Keep shared calculations independent of engine services. Validate new Tune fields and document units/ranges. Preserve server-only authority and deterministic cleanup.
3. Add contract tests for numerical/network behavior. Use Studio harnesses for physics; a passing pure calculation does not prove contact dynamics.
4. Run tools/build.py then tools/check.py. Commit regenerated public packages with source changes. CI checks parsing/compilation, headless contracts and artifact reproducibility; it does not run Roblox physics.
5. Run affected Studio tests and attach before/after evidence with device, player count and source revision. Stop Play, reset the simulator and remove temporary fixtures.

No dynamic require(assetId), unreviewed Toolbox scripts, real purchases, production DataStores or third-party artwork under the MIT license. Avoid promises of device/network performance without measurements. Breaking schema/API changes require migration notes. Do not relabel the release candidate stable without closing the readiness gates.
