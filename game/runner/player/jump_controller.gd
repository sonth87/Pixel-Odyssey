class_name JumpController
extends RefCounted
## Decides when a jump starts (with coyote time and jump buffer) and whether the hold is still extending it.

var _physics: JumpPhysics
var _ticks_since_press := 1 << 30
var _ticks_since_ground := 0
var _hold_ticks := 0
var _hold_open := false


func _init(physics: JumpPhysics) -> void:
	_physics = physics


## Call once per tick with the grounded state from the end of the previous tick; true when a jump starts now.
func try_start(input: TickInput, grounded: bool) -> bool:
	_ticks_since_press = 0 if input.pressed else _ticks_since_press + 1
	_ticks_since_ground = 0 if grounded else _ticks_since_ground + 1
	var buffered := _ticks_since_press <= _physics.buffer_ticks
	var can_jump := _ticks_since_ground <= _physics.coyote_ticks
	if not (buffered and can_jump):
		return false
	_ticks_since_press = 1 << 30
	_ticks_since_ground = _physics.coyote_ticks + 1
	_hold_ticks = 0
	_hold_open = true
	return true


## Once released, a jump cannot be extended again.
func holding(input: TickInput, vy: int) -> bool:
	if not (_hold_open and input.held and vy < 0 and _hold_ticks < _physics.max_hold_ticks):
		_hold_open = false
		return false
	_hold_ticks += 1
	return true
