extends Node2D
## Development greybox: a full RunSimulation on the greybox island, drawn with plain rectangles, to tune
## game feel before real art. Tap/click/Space jumps (hold for higher). F1 overlay, F4 slow motion, R restart.

const ISLAND := "res://content/common/greybox/greybox_island.tres"
const PLAYER_SCREEN_X := 64
const RESTART_DELAY_TICKS := 24
const TIME_SCALES: Array[float] = [1.0, 0.5, 0.25]
const SKY := Color(0.988, 0.961, 0.918)
const GROUND := Color(0.894, 0.863, 0.82)
const GROUND_EDGE := Color(0.78, 0.74, 0.69)
const PLAYER := Color(0.33, 0.33, 0.36)
const PLAYER_DEAD := Color(0.62, 0.22, 0.2)
const HAZARD := Color(0.55, 0.38, 0.3)
const SPIKES := Color(0.75, 0.2, 0.18)
const CRATE := Color(0.72, 0.6, 0.45)
const CRATE_EDGE := Color(0.45, 0.35, 0.24)
const ENEMY := Color(0.45, 0.3, 0.55)
const TELEGRAPH := Color(0.85, 0.55, 0.2)
const DEFEATED := Color(0.75, 0.72, 0.7)

@export var run_seed := 1

var _physics: JumpPhysics
var _island: IslandData
var _run: RunSimulation
var _dead_ticks := 0
var _overlay := true
var _time_scale_index := 0
var _jump_meter := JumpMeter.new()

@onready var _input: InputCollector = %InputCollector
@onready var _hud: Label = %Hud


func _ready() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_island = load(ISLAND)
	_restart()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_F1:
			_overlay = not _overlay
		KEY_F4:
			_time_scale_index = (_time_scale_index + 1) % TIME_SCALES.size()
			Engine.time_scale = TIME_SCALES[_time_scale_index]
		KEY_R:
			_restart()


func _physics_process(_delta: float) -> void:
	var input := _input.collect()
	if _run.body.is_dead():
		_dead_ticks += 1
		if input.pressed and _dead_ticks > RESTART_DELAY_TICKS:
			_restart()
		return
	var was_grounded := _run.body.grounded
	_run.step(input)
	_jump_meter.observe(_run.body, input, was_grounded, _physics)


func _process(_delta: float) -> void:
	_hud.visible = _overlay
	_hud.text = _hud_text()
	queue_redraw()


func _draw() -> void:
	var width := get_viewport_rect().size.x
	var camera := Fixed.to_px(_run.body.x) - PLAYER_SCREEN_X
	draw_rect(Rect2(0, 0, width, 180), SKY)
	_draw_terrain(camera, width)
	for obstacle in _run.obstacles:
		_draw_obstacle(obstacle, camera)
	_draw_box(_run.body.hurtbox(), camera, PLAYER_DEAD if _run.body.is_dead() else PLAYER)


func _draw_terrain(camera: int, width: float) -> void:
	var terrain := _run.terrain
	for i in terrain.span_count():
		var ground_y := terrain.span_y(i)
		if ground_y == Terrain.NO_GROUND:
			continue
		var start := terrain.span_start(i) - camera
		var end := (terrain.span_start(i + 1) - camera) if i + 1 < terrain.span_count() else int(width)
		draw_rect(Rect2(start, ground_y, end - start, 180 - ground_y), GROUND)
		draw_rect(Rect2(start, ground_y, end - start, 1), GROUND_EDGE)


func _draw_box(box: Rect2i, camera: int, color: Color) -> void:
	var x := Fixed.to_px(box.position.x) - camera
	var y := Fixed.to_px(box.position.y)
	draw_rect(Rect2(x, y, Fixed.to_px(box.size.x), Fixed.to_px(box.size.y)), color)


## Solid-top obstacles look like crates; deadly ones get spikes on top so the difference reads at a glance.
func _draw_obstacle(obstacle: ObstacleState, camera: int) -> void:
	var box := obstacle.hitbox()
	if obstacle.data.solid_top:
		_draw_box(box, camera, CRATE_EDGE)
		_draw_box(box.grow(-Fixed.SUB), camera, CRATE)
		return
	_draw_box(box, camera, _obstacle_color(obstacle))
	if obstacle.defeated or obstacle.data.category.begins_with("enemy"):
		return
	var left := Fixed.to_px(box.position.x) - camera
	var top := Fixed.to_px(box.position.y)
	for x in range(left, left + Fixed.to_px(box.size.x) - 1, 3):
		draw_colored_polygon(PackedVector2Array([Vector2(x, top), Vector2(x + 3, top), Vector2(x + 1.5, top - 3)]), SPIKES)


func _obstacle_color(obstacle: ObstacleState) -> Color:
	if obstacle.defeated:
		return DEFEATED
	if obstacle.motion.phase == ObstacleMotion.Phase.TELEGRAPH:
		return TELEGRAPH
	return ENEMY if obstacle.data.category.begins_with("enemy") else HAZARD


func _restart() -> void:
	_run = RunSimulation.new(_physics, _island, RngStreams.new(run_seed))
	run_seed += 1
	_dead_ticks = 0
	_input.reset()


func _hud_text() -> String:
	var body := _run.body
	var status := "DEAD (%s) - tap to retry" % RunnerBody.Death.keys()[body.death] if body.is_dead() else _jump_meter.last
	return "%d m  %d px/s  chunk %s  lvl %d  stomps %d  seed %d\n%s\nF1 overlay  F4 slow-mo x%.2f  R restart" % [
		_run.distance_m(), _run.speed_px_per_second(body.x), _run.spawner.chunk_id_at(Fixed.to_px(body.x)),
		_run.target_difficulty(body.x), _run.stomps, run_seed - 1, status, TIME_SCALES[_time_scale_index]]


## Measures the last jump (hold ticks, height) for tuning.
class JumpMeter:
	var last := ""
	var _hold := 0
	var _tracking := false
	var _takeoff := 0
	var _apex := 0

	func observe(body: RunnerBody, input: TickInput, was_grounded: bool, physics: JumpPhysics) -> void:
		if was_grounded and body.vy < 0:
			_tracking = true
			_hold = 0
			_takeoff = body.y - body.vy
			_apex = body.y
		if _tracking and input.held and body.vy < 0:
			_hold = mini(_hold + 1, physics.max_hold_ticks)
		elif not input.held:
			_tracking = false
		_apex = mini(_apex, body.y)
		if body.grounded and not was_grounded:
			var height := float(_takeoff - _apex) / Fixed.SUB
			last = "last jump: hold %d/%d ticks, %.1f px high" % [_hold, physics.max_hold_ticks, height]
