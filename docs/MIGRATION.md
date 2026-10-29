# A-Chassis → A-XZF migration

A-XZF is independently implemented. Migration reads geometry and wheel positions, never requires the old Tune, and never runs legacy scripts. Actual tested models and limitations: [COMPATIBILITY.md](COMPATIBILITY.md).

## Quick conversion

1. Back up your model and stop Play. Install AXZF, including ServerStorage/AXZFExamples/VehicleTune.
2. Obtain your vehicle separately and put it in inert ServerStorage. Select its one Model in Explorer.
3. Run in the Studio Command Bar:

```lua
local Migration=require(game.ServerScriptService.AXZFServer.Migration)
local car,report=Migration.fromSelection({
    name="MyCar_AXZF", at=CFrame.new(0,5,30),
})
print(game:GetService("HttpService"):JSONEncode(report))
```

The new car is placed in Workspace, tagged AXZFVehicle and selected. Your original stays in ServerStorage. The new copy contains a commented root Tune, fresh Chassis/DriveSeat, individual wheels and spring mounts. Inspect it, then Play.

Tune Power, MaxSpeed, Drive, Radius, suspension, recovery, HUD and Controls in that car's Tune. [Tune reference](TUNING.md). Run DriveTest and JitterTest before adopting.

## Contract and custom tooling

Exactly one nested Model must have DriveSeat, Wheels and A-Chassis Tune. FL/FR/RL/RR must be BaseParts or Models with PrimaryPart, with correct left/right labels. Body/Misc and wheel render mesh/Parts art are retained. Legacy arms, joints, force objects, remotes, scripts and plugins are stripped from the new copy.

```lua
local car,report=Migration.convert(sourceModel,{
    radius=1.4, restLength=1.6, drive="AWD", name="Custom_AXZF",
})
car.Parent=workspace
game:GetService("CollectionService"):AddTag(car,"AXZFVehicle")
```

convert returns an unparented Model. inspect reports source parts/scripts and rejects unsupported structure. All migration calls are Edit-only. Radius is estimated from hub sizes; scaled meshes/oversized hubs need a manual override. One radius is assumed for all four wheels.

Legacy HP, suspension, weight conventions, Tune fields, keys and plugins are not translated. Power is an AXZF force multiplier, not HP. Check radius/mounts/sag, then grip, steering, torque/gears and brakes. Never attach both chassis to one assembly.

The three tested legacy layouts use older A-Chassis conventions; modern v1.7.2 model compatibility is unverified. Rollback means stopping AXZF and restoring the original runtime/model revision.
