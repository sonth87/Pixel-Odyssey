class_name ObstacleMotion
extends RefCounted
## Integer runtime behavior of one obstacle. The base motion never moves and never changes phase.

enum Phase { IDLE, TELEGRAPH, ACTIVE }

var phase := Phase.IDLE


## Returns how far the obstacle moves toward the player this tick, in subpixels.
func step(_distance_to_player: int) -> int:
	return 0


func clone() -> ObstacleMotion:
	var copy := ObstacleMotion.new()
	copy.phase = phase
	return copy
