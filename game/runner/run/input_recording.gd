class_name InputRecording
extends RefCounted
## Jump input of a run, stored only where it changes: Vector3i(tick, pressed, held)
## (docs/05-technical/08-input-rendering-determinism.md §1.5).

var events: Array[Vector3i] = []

var _last_held := false


func record(tick: int, input: TickInput) -> void:
	if input.pressed or input.held != _last_held:
		events.append(Vector3i(tick, int(input.pressed), int(input.held)))
		_last_held = input.held


func replay() -> InputReplay:
	return InputReplay.new(events)
