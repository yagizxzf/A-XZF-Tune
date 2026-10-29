# UI feedback

## 2026-10-29 — Driving instruments follow the circular reference
Rule: when the requested reference is A-Chassis-style cockpit instruments, use a circular gauge with clear speed, RPM and gear hierarchy rather than treating similarity as data content alone.
Why: the developer reviewed the flat rectangular preview and requested a round gauge closer to A-Chassis.
Apply: revise desktop/mobile gauge previews together; retain separate mobile driving/parking/exit buttons and hideable key help. Keep implementation/art original.

This project-local record follows the user's requirement that all development stays within A-XZF-Tune; shared skill files are not modified.

- Verify the actual visible user place, not only a separate demo. The original place retained its old driver and lacked UI modules.
- Use ScriptEditorService.UpdateSourceAsync for generated Command Bar installs. Setting Source alone left the open Fleet editor buffer stale, so Play executed the older version. Reuse protected StarterPlayerScripts without reassigning Parent.
