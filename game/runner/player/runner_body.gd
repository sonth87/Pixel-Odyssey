class_name RunnerBody
extends RefCounted
## Deterministic integer movement of the runner: auto-run, jump, landing, steps, walls and pits
## (docs/01-game-design/09-interaction-rules.md §7). Positions are subpixels; `y` is the feet line, growing downward.

enum Death { NONE, CONTACT, PIT, WALL }

const FOOT_INSET_PX := 2
const STEP_UP_PX := 4
const CORNER_CORRECTION_PX := 6
const HURTBOX_HEIGHT_PX := 20

var x := 0
var y := 0
var vy := 0
var grounded := true
var death := Death.NONE
var half_width_px := 5
var death_y := Terrain.NO_GROUND

var _physics: JumpPhysics
var _jump: JumpController
var _terrain: Terrain


func _init(physics: JumpPhysics, terrain: Terrain) -> void:
	_physics = physics
	_jump = JumpController.new(physics)
	_terrain = terrain


func is_dead() -> bool:
	return death != Death.NONE


func step(input: TickInput, speed: int) -> void:
	if is_dead():
		return
	if _jump.try_start(input, grounded):
		vy = -_physics.jump_velocity
		grounded = false
	var holding := _jump.holding(input, vy)
	_move_forward(speed)
	if is_dead() or (grounded and _support(0) == y):
		return
	grounded = false
	vy = _physics.next_velocity(vy, holding)
	y += vy
	_land_or_fall()


## Stomp rebound; holding the button extends it like a jump.
func bounce() -> void:
	vy = -_physics.stomp_velocity
	grounded = false
	_jump.open_hold(_physics.stomp_max_hold_ticks)


func kill(cause: Death) -> void:
	death = cause


func hurtbox() -> Rect2i:
	var height := Fixed.from_px(HURTBOX_HEIGHT_PX)
	var half := Fixed.from_px(half_width_px)
	return Rect2i(x - half, y - height, half * 2, height)


func clone() -> RunnerBody:
	var copy := RunnerBody.new(_physics, _terrain)
	copy.x = x
	copy.y = y
	copy.vy = vy
	copy.grounded = grounded
	copy.death = death
	copy.half_width_px = half_width_px
	copy.death_y = death_y
	copy._jump = _jump.clone()
	return copy


func _move_forward(speed: int) -> void:
	var old_front := Fixed.to_px(x) + half_width_px - 1
	x += speed
	var new_front := Fixed.to_px(x) + half_width_px - 1
	if new_front <= old_front:
		return
	var wall_top := _terrain.highest_in(old_front + 1, new_front)
	if wall_top == Terrain.NO_GROUND or Fixed.from_px(wall_top) >= y:
		return
	var rise := y - Fixed.from_px(wall_top)
	var limit := STEP_UP_PX if grounded else CORNER_CORRECTION_PX
	if rise > Fixed.from_px(limit):
		kill(Death.WALL)
		return
	y = Fixed.from_px(wall_top)
	vy = 0
	grounded = true


func _land_or_fall() -> void:
	var support := _support(FOOT_INSET_PX)
	if vy >= 0 and support != Terrain.NO_GROUND and y >= support and y - vy <= support:
		y = support
		vy = 0
		grounded = true
	elif y > death_y:
		kill(Death.PIT)


## Highest ground under the feet in subpixels. Landing ignores the outer `inset_px` of each side (edge
## tolerance); staying on the ground uses the full width so a step just climbed keeps supporting the runner.
func _support(inset_px: int) -> int:
	var x_px := Fixed.to_px(x)
	var top := _terrain.highest_in(x_px - half_width_px + inset_px, x_px + half_width_px - 1 - inset_px)
	return top if top == Terrain.NO_GROUND else Fixed.from_px(top)
