class_name StaticBehavior
extends ObstacleBehaviorData
## Stands still.


func create_motion() -> ObstacleMotion:
	return ObstacleMotion.new()
