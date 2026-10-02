class_name ChargerBehavior
extends ObstacleBehaviorData
## Waits until the player is within trigger distance, telegraphs, then runs toward the player.

@export_range(160, 400) var trigger_distance_px := 200
@export var telegraph_time := 0.25
@export var move_speed := 60.0


func create_motion() -> ObstacleMotion:
	return ChargerMotion.new(trigger_distance_px, Fixed.ticks(telegraph_time), Fixed.velocity(move_speed))


func approach_speed() -> float:
	return move_speed
