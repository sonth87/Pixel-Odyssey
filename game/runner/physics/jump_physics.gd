class_name JumpPhysics
extends RefCounted
## Compiled integer jump constants (subpixels, ticks) and the vertical integration step shared by the game
## and the chunk validator, so both always agree on reach.

var gravity: int
var hold_gravity: int
var fall_gravity: int
var jump_velocity: int
var max_fall_speed: int
var max_hold_ticks: int
var coyote_ticks: int
var buffer_ticks: int
var stomp_velocity: int
var stomp_max_hold_ticks: int


func gravity_for(vy: int, holding: bool) -> int:
	if holding and vy < 0:
		return hold_gravity
	if vy > 0:
		return fall_gravity
	return gravity


func next_velocity(vy: int, holding: bool) -> int:
	return mini(vy + gravity_for(vy, holding), max_fall_speed)
