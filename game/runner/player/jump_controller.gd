class_name JumpController
extends RefCounted
## Decides when a jump starts (with coyote time and jump buffer) and whether the hold is still extending it.

const NEVER := 1 << 30

var _physics: JumpPhysics
var _ticks_since_press := NEVER
var _ticks_since_ground := 0
var _hold_ticks := 0
var _hold_limit := 0
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
	_ticks_since_press = NEVER
	_ticks_since_ground = _physics.coyote_ticks + 1
	open_hold(_physics.max_hold_ticks)
	return true


func open_hold(limit_ticks: int) -> void:
	_hold_ticks = 0
	_hold_limit = limit_ticks
	_hold_open = true


## Once released, a jump cannot be extended again.
func holding(input: TickInput, vy: int) -> bool:
	if not (_hold_open and input.held and vy < 0 and _hold_ticks < _hold_limit):
		_hold_open = false
		return false
	_hold_ticks += 1
	return true


func clone() -> JumpController:
	var copy := JumpController.new(_physics)
	copy._ticks_since_press = _ticks_since_press
	copy._ticks_since_ground = _ticks_since_ground
	copy._hold_ticks = _hold_ticks
	copy._hold_limit = _hold_limit
	copy._hold_open = _hold_open
	return copy
