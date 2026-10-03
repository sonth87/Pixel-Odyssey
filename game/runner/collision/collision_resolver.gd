class_name CollisionResolver
## The tick order and interaction matrix of docs/01-game-design/09-interaction-rules.md §3–6. Rush and an
## active transform both end up as entries in `host.modifiers()` (a RushEffect, or the transform's own
## DestroyOnContactEffect(*) while ACTIVE) — so "lao tốc hoặc biến hình" (§3 step 1) and "phá khi chạm"
## (§3 step 2) collapse into the same filter check instead of two special cases.

const STOMP_TOLERANCE_PX := 4


## Obstacles must be ordered left to right. Returns the obstacles stomped this tick.
static func resolve(body: RunnerBody, obstacles: Array[ObstacleState], previous_feet_y: int, host: EffectHost) -> Array[ObstacleState]:
	var stomped: Array[ObstacleState] = []
	if body.is_dead():
		return stomped
	var modifiers := host.modifiers()
	for obstacle in obstacles:
		if obstacle.defeated or obstacle.data.solid_top or not body.hurtbox().intersects(obstacle.hitbox()):
			continue
		var category := obstacle.data.category
		if modifiers.rush or modifiers.destroys(category):
			obstacle.defeated = obstacle.data.destructible
			continue
		if modifiers.phases_through(category):
			continue
		if host.is_invulnerable():
			continue
		if is_stomp(body, obstacle, previous_feet_y):
			obstacle.defeated = true
			body.bounce()
			stomped.append(obstacle)
			continue
		if host.has_shield():
			host.break_shield()
			obstacle.defeated = obstacle.data.destructible
			continue
		body.kill(RunnerBody.Death.CONTACT)
		break
	return stomped


static func is_stomp(body: RunnerBody, obstacle: ObstacleState, previous_feet_y: int) -> bool:
	var top := obstacle.hitbox().position.y
	return obstacle.data.stompable and body.vy > 0 and previous_feet_y <= top + Fixed.from_px(STOMP_TOLERANCE_PX)
