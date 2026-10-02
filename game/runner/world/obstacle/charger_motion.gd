class_name ChargerMotion
extends ObstacleMotion
## Triggered by player distance (not time) so every speed and every run meets the same situation (D-025).

var _trigger: int
var _telegraph_ticks: int
var _speed: int
var _timer := 0


func _init(trigger_px: int, telegraph_ticks: int, speed: int) -> void:
	_trigger = Fixed.from_px(trigger_px)
	_telegraph_ticks = telegraph_ticks
	_speed = speed


func step(distance_to_player: int) -> int:
	match phase:
		Phase.IDLE:
			if distance_to_player <= _trigger:
				phase = Phase.TELEGRAPH
				_timer = _telegraph_ticks
		Phase.TELEGRAPH:
			_timer -= 1
			if _timer <= 0:
				phase = Phase.ACTIVE
		Phase.ACTIVE:
			return _speed
	return 0


func clone() -> ObstacleMotion:
	var copy := ChargerMotion.new(0, _telegraph_ticks, _speed)
	copy._trigger = _trigger
	copy._timer = _timer
	copy.phase = phase
	return copy
