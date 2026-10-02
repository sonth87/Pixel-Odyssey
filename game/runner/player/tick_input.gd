class_name TickInput
extends RefCounted
## Jump button state for one simulation tick.

var pressed := false
var held := false


static func of(pressed_now: bool, held_now: bool) -> TickInput:
	var input := TickInput.new()
	input.pressed = pressed_now
	input.held = held_now
	return input
