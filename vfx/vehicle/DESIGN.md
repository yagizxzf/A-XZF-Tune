# Vehicle VFX

Purpose: grounded tyre slip/handbrake smoke and dirt-surface dust, visible behind a driving car without hiding the road. No fire, explosions, magic glow, camera shake or geometric smoke objects.

Palette: warm grey smoke, cool grey smoke, desaturated earth dust, dark grit. Three ParticleEmitter layers: body (0.45–0.85 s), secondary billow (0.7–1.1 s), grit (0.2–0.4 s). Burst attributes EmitCount/EmitDelay/EffectDuration are retained for artist editing. Smoke grows and thins; grit spreads quickly and dies first. Low particle budget, no always-on emitters, no per-frame server particle replication.

Server decides slip/ground material; UnreliableRemoteEvent carries name + contact CFrame + intensity. Client culls distant effects and applies a token budget; missing effects never affect physics. Tune.VFX and VFXIntensity control the effect. Two original drawn alpha textures are kept with the script and asset map here. Preview locally before the single two-image upload batch.

Checks: close and driving-camera holds at 0.05, 0.2, 0.5, 0.9 s; cleanup after the effect. Skill: roblox-vfx. Imported Emit/Build/Capture tooling retains its MIT attribution; vehicle effect settings/textures are original.
