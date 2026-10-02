class_name ChunkPathSearch
extends RefCounted
## Searches jump decisions through one chunk at one constant speed. The runner's x depends only on the tick,
## so every obstacle's position per tick is precomputed once; the search branches only at grounded ticks:
## keep running, or jump holding for one of ChunkValidator.HOLD_OPTIONS ticks.

var _physics: JumpPhysics
var _speed: int
var _terrain := Terrain.new()
var _start: RunnerBody
var _goal: int
var _hitboxes: Array[Array] = []


func _init(layout: ChunkLayout, picks: Dictionary, physics: JumpPhysics, speed: int) -> void:
	_physics = physics
	_speed = speed
	var slot_data: Array[ObstacleData] = []
	for category in layout.slot_categories:
		slot_data.append(picks[category])
	_terrain.append_span(-ChunkValidator.RUNWAY_PX, layout.entry_y())
	for span in ChunkGround.spans(layout, slot_data):
		_terrain.append_span(span.x, span.y)
	_terrain.append_span(layout.width_px, layout.exit_y())
	_start = RunnerBody.new(physics, _terrain)
	_start.x = Fixed.from_px(-(ChunkValidator.RUNWAY_PX >> 1))
	_start.y = Fixed.from_px(layout.entry_y())
	_start.death_y = Fixed.from_px(RunSimulation.DEATH_Y_PX)
	_goal = Fixed.from_px(layout.width_px)
	_build_timeline(layout, picks)


func passable() -> bool:
	var stack: Array = [[_start, 0]]
	var seen := {}
	while not stack.is_empty():
		var state: Array = stack.pop_back()
		var body: RunnerBody = state[0]
		var tick: int = state[1]
		if body.x >= _goal:
			return true
		var key := Vector2i(tick, body.y)
		if seen.has(key):
			continue
		seen[key] = true
		for hold in ChunkValidator.HOLD_OPTIONS:
			_push(stack, _advance(body, tick, true, hold))
		_push(stack, _advance(body, tick, false, 0))
	return false


func _push(stack: Array, state: Array) -> void:
	if not state.is_empty():
		stack.append(state)


## Runs from a grounded state until grounded again, the goal, or death; returns [body, tick] or [] on death.
func _advance(from: RunnerBody, tick: int, jump: bool, hold: int) -> Array:
	var body := from.clone()
	for i in ChunkValidator.MAX_AIR_TICKS:
		body.step(TickInput.of(jump and i == 0, jump and i < hold), _speed)
		tick += 1
		if body.is_dead() or _touches_obstacle(body, tick):
			return []
		if body.x >= _goal or body.grounded:
			return [body, tick]
	return []


func _touches_obstacle(body: RunnerBody, tick: int) -> bool:
	if tick >= _hitboxes.size():
		return false
	var hurt := body.hurtbox()
	for box: Rect2i in _hitboxes[tick]:
		if hurt.intersects(box):
			return true
	return false


func _build_timeline(layout: ChunkLayout, picks: Dictionary) -> void:
	var states: Array[ObstacleState] = []
	for i in layout.slots.size():
		var data: ObstacleData = picks[layout.slot_categories[i]]
		if not data.solid_top:
			states.append(ObstacleState.new(data, layout.slots[i].x, layout.slots[i].y))
	var ticks := Fixed.fdiv(_goal - _start.x, _speed) + ChunkValidator.MAX_AIR_TICKS
	var player_x := _start.x
	_hitboxes.append([])
	for t in ticks:
		player_x += _speed
		var boxes: Array[Rect2i] = []
		for state in states:
			state.step(player_x)
			boxes.append(state.hitbox())
		_hitboxes.append(boxes)
