# Vehicle VFX

AXZFTyreSmoke and AXZFSurfaceDust use three layered ParticleEmitters: smoke body, delayed billow and road grit. Original NumPy-drawn textures and recipes live under vfx/vehicle. Emit/Build tooling is MIT-credited in NOTICE.md.

The server chooses rear-contact effects when loaded, faster than 7 studs/s, and slipping sideways >6 or using the parking brake. Sand/Grass/Ground/Mud choose dust. Only name/CFrame/intensity travel over an UnreliableRemoteEvent to nearby players; there is no client request handler. Physics never waits on effects.

Maximum requests: two contacts per vehicle per 1/6 second. Client culling: 180 studs; token bucket: 30 events/second, burst 30. Particle lives are approximately 0.5–1.05 seconds, effect cleanup 1.2 seconds. Finished handles are pruned and textures preload asynchronously. This is not a total GPU performance certification.

Tune.VFX=false or VFXIntensity=0 disables car effects; VFXIntensity supports 0..2.

## Assets

- TyreSmoke: rbxassetid://123244819470159
- RoadGrit: rbxassetid://101186639768027
- Provenance/upload map: vfx/vehicle/assets.json

The source PNGs are MIT. Roblox image availability still depends on moderation and destination permissions. If unavailable in your experience, upload supplied PNGs to your owner/group and replace the IDs in recipes.json and runtime/VehicleRecipes.luau.

## Verification

Used the requested roblox-vfx workflow: custom texture review, held frames at 0.05/0.20/0.50/0.90 seconds in close and driver views, two settled image uploads, re-check with uploaded assets, then live rear-slip/parking-brake playback. Build.previewLeftovers returned empty. A live burst contained 18 client emitters and zero preview addresses; temporary copies expired afterward. Captures are in vfx/vehicle/checks.

No local preview addresses or development Capture/Shapes modules are packaged. View effects at full speed in the local demo and tune intensity for your camera/budget. Engine audio and camera shake are outside this release.
