# Asset provenance and integration

Reviewed 2026-10-29 in Studio place 72435697524161, universe 10773638854. Creator Store search was free Models, verified-creators filter. A verified filter or free price is not proof of authorship or redistribution rights.

## Original kit example

`examples/PrototypeCar.luau` and `TestTrack.luau` are authored for this project and MIT licensed. The orange car has separate doors, hood, trunk, roof, pillars, lights, tire and rim parts. No external mesh/texture/audio dependency. It is a functional test rig, not a finished art asset.

## External car

| Field | Observed value |
|---|---|
| Semantic key | vehicle.integration.creator_car |
| Asset | Model `14215126016`, **Car** |
| Source | [Creator Store](https://create.roblox.com/store/asset/14215126016), query `car` |
| Listed creator | Roblox Resources (as returned by search; no claim this is an official Roblox-authored asset) |
| Observed price | Free, 2026-10-29 |
| Destination | Local Studio test place only; no live publication |
| Original contents | 75 BaseParts, 45 MeshParts, 14 LuaSourceContainers, seats, suspension/mechanics, remotes/effects |
| Sanitized integration | 47 BaseParts, separate body/door/glass/bumpers and four multi-part wheel Models; fresh AXZF root and VehicleSeat |
| Security decision | Imported to ServerStorage.__AssetReview. No original scripts required/executed. Geometry-only allowlist; all foreign mechanics/remotes/effects/scripts excluded |
| External failures | Original textures included inaccessible/mismatched content (14922346201 and 203785492 observed). Adapter removes SurfaceAppearance/texture dependencies; mesh geometry retained |
| Tests | Flat settling, acceleration/braking/steering/watchdog/cleanup/rebind passed; see TESTING.md |
| Rights status | Platform listing observed; no independently verified permission to redistribute the art under MIT. Not included in public packages/source |
| Local retention | Adapted car in author's original Studio and `build/Studio-With-ImportedCar.rbxlx` (ignored by Git); source geometry JSON also ignored |
| Cleanup | Discarded original quarantine package removed after inspection; only geometry copy retained |

## Reproduce the external-art test

Obtain the exact free model separately through Toolbox/Creator Store. Insert into an inert `ServerStorage.__AssetReview` folder, not Workspace; name the wrapper `Car_RobloxResources_Review`. Check provenance/permissions for your own intended use. Inspect the hierarchy again if its published revision changes. Never Play the unreviewed package.

With the demo/source examples installed, in Edit mode:

```lua
local source = game.ServerStorage.__AssetReview.Car_RobloxResources_Review
local car = require(game.ServerStorage.AXZFExamples.CreatorCarAdapter)(source, CFrame.new(12,5,35))
car.Parent = workspace
-- Adapter adds the commented AXZF Tune (Radius=1.5, FWD, TorqueScale=5).
game:GetService("CollectionService"):AddTag(car,"AXZFVehicle")
```

Set Tune before tagging. The specific adapter expects this source hierarchy and fails on changed structure. For unrelated art use the explicit general adapter. Remove the unused source package after keeping an inert backup elsewhere. Public packages deliberately contain only original art generation; inserting the third-party car is an independent acquisition step.

Initially rejected: `133938791811141` had a deleted-creator label and bundled code and was never inserted. `4529389736` was initially skipped, then deliberately acquired during the user's second-round A-Chassis migration request. It and two additional cars were quarantined and migrated without running legacy code; see COMPATIBILITY.md. `6810376207` had a brand-related description and unnecessary provenance ambiguity; not inserted. Search listings are observations, not legal conclusions.

## Additional migration sources

A-Chassis Sedan 4529389736 (Atomicatfo), Police Sedan 5933886177 (Ravenhasabird57, listing asks credit) and SUV 9857510493 (sky031208) were separately obtained on 2026-10-29 for the requested compatibility work. All originals stayed inert in ServerStorage. New rigs retain only art plus authored AXZF Tune. Counts, tested conventions, results and rights caveats are in COMPATIBILITY.md. None of this third-party art is redistributed in public Git packages.

The author's local build/A-XZF-CompatibilityDemo.rbxl includes all four real cars and the prototype. It is ignored by Git. Reproduce by native-exporting ServerStorage.AXZFCompatibilitySources to build/AXZF-CompatibilityCars.rbxm, then running python tools/export_compatibility.py. This optional helper uses rbxmk 0.9.1 with current service descriptors; Windows archive SHA256 387824c3c370d3fd10461b82bbc3cb9e51f4b8fa1293fafac9347675c94d373f. Native binary preserves union/mesh payloads; the older rbxmk XML conversion cannot round-trip current NetAsset properties. Normal public packaging needs no rbxmk.

For the optional native writer, place a Studio API-Dump.json under .tools/rbxmk/ (the tested copy came from the Roblox-Client-Tracker engine-dump mirror), run `python tools/prepare_rbxmk_descriptor.py .tools/rbxmk/API-Dump.json .tools/rbxmk/API-Descriptor.json`, then `python tools/export_compatibility.py`. Raw aliases are decoded without reflection; Service tags are applied only during encoding. The helper writes each local car's authored mass explicitly in Tune because rbxmk 0.9.1 does not correctly decode current PhysicalProperties. This also makes copied local cars independent of that serialized density. The final file was reopened and all five bound vehicles, dimensions, 45 MeshParts, 31 unions and 75 unit tests were verified.

## Mobile cockpit icons (0.3)

Nine selected Lucide SVGs and derived white PNGs are redistributed under Lucide ISC / listed Feather MIT terms, with the complete notice in licenses/Lucide-LICENSE.txt. Official source: https://github.com/lucide-icons/lucide. Selection/provenance: ui/icon-pack/provenance.json; mapping: ui/icons.json; uploads: ui/assets.json. The circle_parking action uses circle-pause, not a copied vehicle HUD graphic. These icon terms are separate from the kit MIT license. External car meshes/unions remain excluded.

0.4 active mobile controls use original physical-object rasters generated with built-in image_gen. See ui/art/v4/PROMPTS.md, provenance.json and uploads.json. Five new images uploaded; unchanged near-identical raster hashes alias an existing upload. The former steering-wheel cell and Lucide source art remain historical source only, not active mobile controls.
