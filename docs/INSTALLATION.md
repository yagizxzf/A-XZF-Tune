# Installation

## Standalone evaluation

Download the repository and open `build/A-XZF-Tune-Demo.rbxlx` with Roblox Studio. It was generated from source and opened in a separate Studio instance to verify boot. Press Play: the orange original multi-part car, track, grip patch, ramp and bumps appear. A spawn is created if none exists. Enter DriveSeat by walking onto it. Tests never run automatically in normal Play.

## Existing place

Back up your place. Insert `build/A-XZF-Tune.rbxmx` through Studio's Insert from File. Expand the `A-XZF-Tune` wrapper:

| Wrapper folder | Destination |
|---|---|
| ReplicatedStorage/AXZF | ReplicatedStorage |
| ReplicatedStorage/VFX | ReplicatedStorage |
| ServerScriptService/AXZFServer | ServerScriptService |
| StarterPlayer/StarterPlayerScripts/Driver | StarterPlayer/StarterPlayerScripts |
| StarterPlayer/StarterPlayerScripts/VehicleEffects | StarterPlayer/StarterPlayerScripts |
| ServerStorage/AXZFExamples/VehicleTune | ServerStorage/AXZFExamples |

Move the contents, not duplicate Roblox service folders into Workspace. Delete the empty wrapper. `AXZFServer.Bootstrap` builds the cockpit template and starts the fleet once. If you manage fleet startup yourself, remove/disable Bootstrap, perform its UI template setup, then call `Fleet.start()` once. The included VehicleTune template supports configuration/migration; other examples/tests are optional. The package does not publish your game or make web requests.

Set up your vehicle using [the rig contract](MODEL-INTEGRATION.md), then tag the Model `AXZFVehicle` using Studio's Tag Editor or `CollectionService:AddTag(model,"AXZFVehicle")`. Tag only after geometry and Tune are ready. Late-spawned pre-tagged models are supported. Failures set `AXZFError` on the Model and warn with a reason. Fix the issue, then remove/re-add the tag to retry.

## Source workflows

Python 3.10+ is sufficient for `python tools/build.py`. It creates the model, demo and an optional `build/InstallDemo.luau` command-bar installer. The installer is intended for an isolated evaluation place and replaces only its named AXZF scripts; do not run it over local modifications without a backup.

Rojo is optional: use `default.project.json` with your chosen compatible Rojo installation (`rojo build default.project.json -o build/RojoDemo.rbxlx` or `rojo serve`). This session verified the Python packaging path; the machine's Aftman Rojo shim was unconfigured, so a Rojo build is not claimed as tested.

For CLI checks download official Luau 0.744. Linux archive SHA256: `6506f0852c623aaffcb28494aac16c26dc04a269ea0e16cc0aafc8c8ac79f3ec`; Windows: `fde3e22c557aac6afe20a34e8050b7d8c290fa42638c04274a307ed5d0ef0db8`. Put executables in `.tools/luau/`. Run the command from README; on Windows append `.exe` to both executable paths. `.tools` is ignored by Git.

## Update / uninstall

Stop Play, back up the place and retain your model geometry/Tune. Remove the old runtime folders, Driver and VehicleEffects, then install the new version; do not leave two Bootstraps. For runtime removal, remove the vehicle tag or call your fleet's `stop()` first. This restores bound geometry and removes owned joints/remotes. Keep schema-version changes in version control and compare Tune defaults when updating. No persistent player data needs migration.
