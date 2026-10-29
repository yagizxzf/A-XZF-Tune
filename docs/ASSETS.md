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
-- Add your own root Tune ModuleScript: return {Radius=1.5,Drive="FWD",TorqueScale=5}
game:GetService("CollectionService"):AddTag(car,"AXZFVehicle")
```

Set Tune before tagging. The specific adapter expects this source hierarchy and fails on changed structure. For unrelated art use the explicit general adapter. Remove the unused source package after keeping an inert backup elsewhere. Public packages deliberately contain only original art generation; inserting the third-party car is an independent acquisition step.

Rejected search alternatives: `133938791811141` had a deleted-creator label and bundled code; `4529389736` explicitly contained another A-Chassis vehicle. Neither was inserted. `6810376207` had a brand-related description and unnecessary provenance ambiguity; not inserted. Search listings are observations, not legal conclusions.
