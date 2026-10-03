class_name JumpMultEffect
extends EffectData
## Multiplies jump takeoff velocity. Needs a destroy_on_contact covering air/falling/projectile
## alongside it above 1.0 (invariant E3) since a higher jump can reach "jump low only" hazard bands.

@export_range(1.0, 2.0) var factor := 1.0
