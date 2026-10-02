extends Node2D
## Development greybox: the runner on flat ground with random pits, to tune jump feel before real chunks exist.
## Tap/click/Space to jump, hold to jump higher. F2/F3 change speed, R restarts.

const GROUND_Y_PX := 148
const PLAYER_SCREEN_X := 64
const HURTBOX := Vector2i(10, 20)
const RESTART_DELAY_TICKS := 24
const SPEED_STEP := 20.0
const PIT_GAP_PX := Vector2i(160, 360)
const PIT_WIDTH_PX := Vector2i(24, 56)
const MARKER_SPACING_PX := 32
const SKY := Color(0.988, 0.961, 0.918)
const GROUND := Color(0.894, 0.863, 0.82)
const MARKER := Color(0.78, 0.74, 0.69)
const PLAYER := Color(0.33, 0.33, 0.36)
const PLAYER_DEAD := Color(0.62, 0.22, 0.2)

@export var speed_px := 160.0
@export var run_seed := 1

var _physics: JumpPhysics
var _body: RunnerBody
var _rng: RandomNumberGenerator
var _pits: Array[Vector2i] = []
var _dead_ticks := 0
var _hold_ticks := 0
var _tracking_hold := false
var _apex := 0
var _last_jump := ""

@onready var _input: InputCollector = %InputCollector
@onready var _hud: Label = %Hud


func _ready() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_restart()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_F2:
			speed_px = maxf(speed_px - SPEED_STEP, SPEED_STEP)
		KEY_F3:
			speed_px += SPEED_STEP
		KEY_R:
			_restart()


func _physics_process(_delta: float) -> void:
	var input := _input.collect()
	if _body.dead:
		_dead_ticks += 1
		if input.pressed and _dead_ticks > RESTART_DELAY_TICKS:
			_restart()
		return
	_extend_pits()
	var was_grounded := _body.grounded
	_body.step(input, Fixed.velocity(speed_px))
	_measure_jump(input, was_grounded)


func _process(_delta: float) -> void:
	_hud.text = _hud_text()
	queue_redraw()


func _draw() -> void:
	var width := get_viewport_rect().size.x
	var camera_px := Fixed.to_px(_body.x) - PLAYER_SCREEN_X
	draw_rect(Rect2(0, 0, width, 180), SKY)
	draw_rect(Rect2(0, GROUND_Y_PX, width, 180 - GROUND_Y_PX), GROUND)
	for pit in _pits:
		draw_rect(Rect2(pit.x - camera_px, GROUND_Y_PX, pit.y - pit.x, 180 - GROUND_Y_PX), SKY)
	var first_marker := camera_px - posmod(camera_px, MARKER_SPACING_PX)
	for marker_x in range(first_marker, camera_px + int(width) + MARKER_SPACING_PX, MARKER_SPACING_PX):
		if _ground_px(marker_x) != RunnerBody.NO_GROUND:
			draw_rect(Rect2(marker_x - camera_px, GROUND_Y_PX + 2, 2, 2), MARKER)
	var feet := Fixed.to_px(_body.y)
	var color := PLAYER_DEAD if _body.dead else PLAYER
	draw_rect(Rect2(PLAYER_SCREEN_X - HURTBOX.x / 2, feet - HURTBOX.y, HURTBOX.x, HURTBOX.y), color)


func _restart() -> void:
	_rng = RngStreams.new(run_seed).stream(&"chunks")
	run_seed += 1
	_pits.clear()
	_body = RunnerBody.new(_physics, _ground)
	_body.y = Fixed.from_px(GROUND_Y_PX)
	_body.death_y = Fixed.from_px(196)
	_body.half_width_px = HURTBOX.x / 2
	_dead_ticks = 0
	_input.reset()
	_extend_pits()


func _extend_pits() -> void:
	var player_px := Fixed.to_px(_body.x)
	while _pits.is_empty() or _pits[-1].y < player_px + 600:
		var start: int = (_pits[-1].y if not _pits.is_empty() else 240) + _rng.randi_range(PIT_GAP_PX.x, PIT_GAP_PX.y)
		_pits.append(Vector2i(start, start + _rng.randi_range(PIT_WIDTH_PX.x, PIT_WIDTH_PX.y)))
	while _pits.size() > 1 and _pits[0].y < player_px - 400:
		_pits.pop_front()


func _ground(x: int) -> int:
	var ground_px := _ground_px(Fixed.to_px(x))
	return ground_px if ground_px == RunnerBody.NO_GROUND else Fixed.from_px(ground_px)


func _ground_px(x_px: int) -> int:
	for pit in _pits:
		if x_px >= pit.x and x_px < pit.y:
			return RunnerBody.NO_GROUND
	return GROUND_Y_PX


func _measure_jump(input: TickInput, was_grounded: bool) -> void:
	if was_grounded and _body.vy < 0:
		_tracking_hold = true
		_hold_ticks = 0
		_apex = _body.y
	if _tracking_hold and input.held and _body.vy < 0:
		_hold_ticks = mini(_hold_ticks + 1, _physics.max_hold_ticks)
	elif not input.held:
		_tracking_hold = false
	_apex = mini(_apex, _body.y)
	if _body.grounded and not was_grounded:
		var height := float(Fixed.from_px(GROUND_Y_PX) - _apex) / Fixed.SUB
		_last_jump = "last jump: hold %d/%d ticks, %.1f px high" % [_hold_ticks, _physics.max_hold_ticks, height]


func _hud_text() -> String:
	var meters := Fixed.to_px(_body.x) / 16
	var status := "DEAD - tap to retry" if _body.dead else _last_jump
	return "%d m   %d px/s   %s\nF2/F3 speed   R restart" % [meters, int(speed_px), status]
