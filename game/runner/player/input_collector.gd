class_name InputCollector
extends Node
## Queues jump input as events arrive and hands the simulation one TickInput per physics tick
## (docs/05-technical/08-input-rendering-determinism.md §2). The first finger down owns the jump.

const ACTION := &"jump"

var _pressed := false
var _held := false
var _touch_index := -1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event as InputEventScreenTouch)
	elif event.is_action(ACTION) and not event.is_echo():
		if event.is_pressed():
			_press()
		else:
			_release()


func collect() -> TickInput:
	var input := TickInput.of(_pressed, _held)
	_pressed = false
	return input


func reset() -> void:
	_pressed = false
	_held = false
	_touch_index = -1


func _on_touch(touch: InputEventScreenTouch) -> void:
	if touch.pressed and not _held:
		_touch_index = touch.index
		_press()
	elif not touch.pressed and touch.index == _touch_index:
		_touch_index = -1
		_release()


func _press() -> void:
	if not _held:
		_pressed = true
	_held = true


func _release() -> void:
	_held = false
