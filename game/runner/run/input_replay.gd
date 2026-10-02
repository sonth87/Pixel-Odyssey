class_name InputReplay
extends RefCounted
## Plays an InputRecording back one tick at a time.

var _events: Array[Vector3i]
var _index := 0
var _held := false


func _init(events: Array[Vector3i]) -> void:
	_events = events


func next(tick: int) -> TickInput:
	var pressed := false
	while _index < _events.size() and _events[_index].x == tick:
		pressed = pressed or _events[_index].y == 1
		_held = _events[_index].z == 1
		_index += 1
	return TickInput.of(pressed, _held)
