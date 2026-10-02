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
var _fail_memo: Dictionary[Vector2i, bool] = {}


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


## One successful sequence of jumps as [{body_before, tick_before, hold}, ...], or [] if none exists
## (also returned when the chunk needs zero jumps — found() distinguishes the two).
## Recursive so the path can be reconstructed (passable() only needs a yes/no and uses an explicit stack).
func find_path() -> Array:
	_fail_memo.clear()
	var result := _search(_start, 0, [])
	return result[1] if result[0] else []


## How many ticks earlier than the jump recorded by find_path() the player could instead have pressed and
## still cleared the same hazard, up to ChunkValidator.MAX_TIMING_WINDOW. ≥ 1 always (the recorded tick
## itself works); this is the "how forgiving is this moment" half of §7.2 — the other half, how late you
## can leave it, is always ~0 by construction, since find_path() prefers running as long as possible
## before jumping, so the recorded tick already is the latest safe one.
func timing_window(event: Dictionary) -> int:
	var safe_states: Array = event.safe_states
	var window := 0
	for i in range(safe_states.size() - 1, -1, -1):
		if window >= ChunkValidator.MAX_TIMING_WINDOW:
			break
		var body: RunnerBody = safe_states[i][0]
		var tick: int = safe_states[i][1]
		var result := _advance(body, tick, true, event.hold)
		if result.is_empty() or not _reachable(result[0], result[1]):
			break
		window += 1
	return window


func _reachable(body: RunnerBody, tick: int) -> bool:
	return body.x >= _goal or _search(body, tick, [])[0]


## Walks forward without jumping for as long as that stays safe (recording each such state in `safe`),
## then — once no-jump finally fails — tries jumping from the most recent safe state backward through
## older ones, so find_path() naturally prefers the latest possible jump and timing_window() can measure
## how much earlier than that still would have worked. Memoizes failure only (x is a pure function of
## tick, so (tick, y) fully keys a state). Returns [found: bool, trail] — trail can be [] on success too
## (zero jumps needed anywhere), which is why success/failure is a flag, not trail.is_empty().
func _search(body: RunnerBody, tick: int, trail: Array) -> Array:
	var safe: Array = []
	while true:
		if body.x >= _goal:
			return [true, trail]
		if _fail_memo.has(Vector2i(tick, body.y)):
			return [false]
		safe.append([body, tick])
		var result := _advance(body, tick, false, 0)
		if result.is_empty():
			break
		body = result[0]
		tick = result[1]
	for i in range(safe.size() - 1, -1, -1):
		var b: RunnerBody = safe[i][0]
		var t: int = safe[i][1]
		for hold in ChunkValidator.HOLD_OPTIONS:
			var result := _advance(b, t, true, hold)
			if not result.is_empty():
				var event := {"body_before": b, "tick_before": t, "hold": hold, "safe_states": safe.slice(0, i + 1)}
				var found := _search(result[0], result[1], trail + [event])
				if found[0]:
					return found
	for state: Array in safe:
		_fail_memo[Vector2i(state[1], (state[0] as RunnerBody).y)] = true
	return [false]


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
