class_name PhaseThroughEffect
extends EffectData
## Ignores CONTACT with a matching category entirely — no destruction, just passes through.

@export var filter: Array[StringName] = ObstacleFilter.ALL
