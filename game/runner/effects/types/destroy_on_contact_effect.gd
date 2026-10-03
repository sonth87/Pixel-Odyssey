class_name DestroyOnContactEffect
extends EffectData
## CONTACT with a matching category destroys it (if destructible) or is phased through (if not)
## instead of killing the player (interaction rules §2–4).

@export var filter: Array[StringName] = ObstacleFilter.ALL
