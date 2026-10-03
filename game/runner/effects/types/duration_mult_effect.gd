class_name DurationMultEffect
extends EffectData
## Multiplies how long every timed effect applied while this is active lasts (Luffy's passive).
## Always safe to stack (no invariant): it only makes protective effects last longer.

@export_range(1.0, 2.0) var factor := 1.0
