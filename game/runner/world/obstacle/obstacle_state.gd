class_name ObstacleState
extends RefCounted
## One obstacle instance in the simulation; the pivot (x, y) is bottom-center in subpixels.

var data: ObstacleData
var x: int
var y: int
var defeated := false
var motion: ObstacleMotion


func _init(obstacle: ObstacleData, x_px: int, ground_y_px: int) -> void:
	data = obstacle
	x = Fixed.from_px(x_px)
	y = Fixed.from_px(ground_y_px)
	motion = obstacle.behavior.create_motion()


func step(player_x: int) -> void:
	if not defeated:
		x -= motion.step(x - player_x)


func hitbox() -> Rect2i:
	var box := data.hitbox
	return Rect2i(x + Fixed.from_px(box.position.x), y + Fixed.from_px(box.position.y),
		Fixed.from_px(box.size.x), Fixed.from_px(box.size.y))


func clone() -> ObstacleState:
	var copy := ObstacleState.new(data, 0, 0)
	copy.x = x
	copy.y = y
	copy.defeated = defeated
	copy.motion = motion.clone()
	return copy
