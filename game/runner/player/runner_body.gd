class_name RunnerBody
extends RefCounted
## Deterministic integer movement of the runner: auto-run, jump, landing and falling into pits.
## Positions are subpixels; `y` is the feet line and grows downward.

const NO_GROUND := 1 << 40
const FOOT_INSET_PX := 2

var x := 0
var y := 0
var vy := 0
var grounded := true
var dead := false
var half_width_px := 5
var death_y := NO_GROUND

var _physics: JumpPhysics
var _jump: JumpController
var _ground: Callable


## `ground` maps an x in subpixels to the ground line there in subpixels, or NO_GROUND over a pit.
func _init(physics: JumpPhysics, ground: Callable) -> void:
	_physics = physics
	_jump = JumpController.new(physics)
	_ground = ground


func step(input: TickInput, speed: int) -> void:
	if dead:
		return
	if _jump.try_start(input, grounded):
		vy = -_physics.jump_velocity
		grounded = false
	var holding := _jump.holding(input, vy)
	x += speed
	if grounded and _ground_under() == y:
		return
	grounded = false
	vy = _physics.next_velocity(vy, holding)
	y += vy
	_land_or_die()


func _land_or_die() -> void:
	var ground_y := _ground_under()
	if vy >= 0 and ground_y != NO_GROUND and y >= ground_y and y - vy <= ground_y:
		y = ground_y
		vy = 0
		grounded = true
	elif y > death_y:
		dead = true


## Highest ground under the feet; the outer FOOT_INSET_PX of each side does not count as support.
func _ground_under() -> int:
	var reach := Fixed.from_px(half_width_px - FOOT_INSET_PX)
	return mini(_ground.call(x - reach), _ground.call(x + reach))
