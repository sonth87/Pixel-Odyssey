@abstract
class_name ObstacleBehaviorData
extends Resource
## Behavior parameters of an obstacle (docs/01-game-design/08-obstacles-enemies-npc.md §4).
## Each subclass compiles its design values into an integer ObstacleMotion for the simulation.


@abstract func create_motion() -> ObstacleMotion


## Speed toward the player in px/s, counted in the approach-speed limit.
func approach_speed() -> float:
	return 0.0
