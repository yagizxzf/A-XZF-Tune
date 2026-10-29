# Security

The supported evaluation candidate uses server network ownership and validates driver identity, living seat occupant, registered model, finite bounded intent, exact payload shape, sequence order and per-player rate. Invalid packets do not refresh the input timeout. Client position/velocity/torque is never accepted. These controls do not secure an entire Roblox experience against every exploit.

Treat root Tune as trusted authored server code. The kit intentionally refuses old vehicle executable content; external example integration clones only allowlisted geometry. Never keep a Toolbox script merely because it is named Tune.

For a suspected vulnerability, use the repository's private GitHub vulnerability reporting if enabled. If unavailable, open an issue containing only a request for a private reporting channel, without exploit instructions or sensitive data. Do not post live credentials, player data or an actionable active-game exploit publicly. No private reporting channel is claimed enabled by this document.

Include affected revision, minimal synthetic reproduction and the authority boundary involved. Patch rollout uses versioned source/packages and backup models. Remove AXZFVehicle tags or stop your Fleet for a local kill switch; deploy your prior runtime/model revision for rollback. The kit has no persistent data migration or purchase grants.
