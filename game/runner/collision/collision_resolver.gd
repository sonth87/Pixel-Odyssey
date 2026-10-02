class_name CollisionResolver
## Contact rules from docs/01-game-design/09-interaction-rules.md §3–5 for the states that exist so far:
## normal contact and stomp. Shields, i-frames and power-up states come with the effect system.

const STOMP_TOLERANCE_PX := 4


## Obstacles must be ordered left to right. Returns the obstacles stomped this tick.
static func resolve(body: RunnerBody, obstacles: Array[ObstacleState], previous_feet_y: int) -> Array[ObstacleState]:
	var stomped: Array[ObstacleState] = []
	if body.is_dead():
		return stomped
	for obstacle in obstacles:
		if obstacle.defeated or obstacle.data.solid_top or not body.hurtbox().intersects(obstacle.hitbox()):
			continue
		if is_stomp(body, obstacle, previous_feet_y):
			obstacle.defeated = true
			body.bounce()
			stomped.append(obstacle)
			continue
		body.kill(RunnerBody.Death.CONTACT)
		break
	return stomped


static func is_stomp(body: RunnerBody, obstacle: ObstacleState, previous_feet_y: int) -> bool:
	var top := obstacle.hitbox().position.y
	return obstacle.data.stompable and body.vy > 0 and previous_feet_y <= top + Fixed.from_px(STOMP_TOLERANCE_PX)
