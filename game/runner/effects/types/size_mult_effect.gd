class_name SizeMultEffect
extends EffectData
## Scales the sprite and hurtbox. Needs a destroy_on_contact covering every category alongside it
## above 1.0 (invariant E2) since a bigger hurtbox no longer fits under low air hazards.

@export_range(1.0, 2.0) var factor := 1.0
