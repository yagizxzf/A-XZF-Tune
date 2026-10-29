# Public integration API

Server modules live under `ServerScriptService.AXZFServer`; shared pure modules under `ReplicatedStorage.AXZF.Shared`. Tests/examples are optional ServerStorage content. Control RemoteEvent and the server-to-client Effects UnreliableRemoteEvent are created at fleet start. Server code stays server-only.

```lua
local Fleet = require(game.ServerScriptService.AXZFServer.Fleet)
-- Disable Bootstrap for custom startup; Fleet prepares the cockpit automatically.
local fleet = Fleet.start()
local vehicle = fleet:get(workspace.MyCar) -- nil when unregistered
if vehicle then
    print(vehicle:getTelemetry().speed)
end
-- fleet:stop() -- idempotent; restores rigs and destroys its RemoteEvent
```

| API | Contract |
|---|---|
| Doctor.inspect(model) | `{ok, errors={{code,message}}, warnings, parts}`; no mutation |
| Adapter.prepare(model, root, seat, wheelMap, restLength) | Editor geometry normalization; returns Doctor report; see model contract |
| Tune.resolve(overrides?) | New immutable resolved config; raises on invalid config |
| Vehicle.new(model, overrides?) | Validates, binds and returns vehicle; raises and rolls back on bind failure |
| vehicle:setInput(intent) | **Trusted server/NPC API**; intent has throttle/steer/brake/handbrake and optional boolean park; refresh at < InputTimeout interval |
| vehicle:clearInput() | Reset held controls to service braking; preserve latched parking request |
| vehicle:setPark(boolean) | Trusted server API; latch/release parking independently of held input |
| TuneEditor.install(model, overrides?) | Edit-only documented Tune creation/update; existing Tune requires explicit overrides |
| vehicle:step(dt) | Advance once before physics; Fleet already calls this; do not double-step |
| vehicle:getTelemetry() | `{speed,rpm,gear,sleeping,stepMs,handbrake,parkRequested,parkState}`; reverse gear = -1 |
| vehicle:destroy() | Idempotent; stops control, unseats occupant, removes owned joints, restores geometry/ownership |
| Fleet.start(options?) | One dispatcher. Optional `{tag,remoteName}` allows isolated server-owned test fleets |
| fleet:add(model) / remove(model) / get(model) | Normal use follows tag and Workspace ancestry automatically |
| fleet:stop() | Disconnects all events, destroys registered vehicles/remotes, clears limiter state |

When driving an NPC manually, instantiate Vehicle without adding the AXZFVehicle tag. Own a single PreSimulation connection that calls step; destroy/disconnect both on removal. Seatless NPCs are not supported by the current rig contract, but a disabled/unoccupied VehicleSeat is fine. Never route untrusted RemoteEvents directly to setInput.

## Observable attributes

`AXZFBound` indicates owned binding. `AXZFError` records setup/runtime quarantine reason. Telemetry is `AXZF_speed`, `AXZF_rpm`, `AXZF_gear`, `AXZF_sleeping`, `AXZF_stepMs`, written at Tune.TelemetryHz. Build your own HUD, sound pitch, brake lights or logging by reading these. Speed is total assembly velocity magnitude; slope/fall motion counts. RPM is a road-speed coupled approximation. `stepMs` is the previous measured script step and is not frame time. Physics remains active when `sleeping` is true; only settled visual work is skipped.

Runtime hooks do not send analytics or retain players' data. A destroyed vehicle loses its AXZF telemetry attributes; setup-error text may remain for diagnosis. Application-owned features should handle nil/removed models and reset their UI/audio on seat exit.

## Network wire contract

```lua
Control:FireServer(model, {
    seq = 1, -- strictly increasing integer, up to 2^31-1, reset after changing seats
    throttle = 0.5, -- -1..1; opposite direction brakes before reversing
    steer = 0, -- -1..1; positive = right
    brake = 0, -- 0..1
    handbrake = false,
    park = false, -- optional; omission preserves the current parking request
})
```

No extra fields are accepted. Server checks player bucket first, then registered model, actual seated living humanoid and character identity, then exact finite/ranged packet and replay order. Limit is 30 commands/s with a 45-command burst; the supplied driver sends 20/s. Old intent expires to braking. Invalid input does not refresh the watchdog. No client position, torque, gear or velocity is accepted. Driver changes reset the sequence and intent. Reliable Roblox event transport still needs latency/adversarial game testing for your experience.

## Failure recovery

A runtime step exception quarantines that vehicle, cleans it up, records AXZFError and allows other vehicles to continue. Re-add the tag after repair. A missing wheel hub or destroyed root invalidates the rig; normal model/tag removal is the supported teardown path. Do not independently destroy essential rig parts while leaving the vehicle registered. Upgrade and rollback use complete source/package revisions; no database schema is involved.

## Migration and client presentation

Edit-only Migration.inspect/convert/fromSelection are documented in MIGRATION.md. Fleet publishes AXZF_Key<Action> and AXZF_Config<DisplayField> from validated Tune values. Telemetry adds AXZF_handbrake, AXZF_recovery and AXZF_recoveryCount. Recovery waits for clear space, slow grounded inversion and a continuous delay; it has a 5-second cooldown. VFX uses only server-decided allowed names/CFrames/intensity; clients render nearby bursts. See HUD.md/VFX.md.

0.3 attributes: `AXZF_parkRequested` is updated immediately; `AXZF_parkState` is Drive/Stopping/Parked at telemetry frequency. Numeric gear is preserved for API consumers; the cockpit displays P when parking is requested. Parking request survives input expiry and driver changes; clearInput does not release it.
