class_name ChunkSpawner
extends RefCounted
## Picks and places chunks ahead of the runner with controlled randomness
## (docs/01-game-design/02-run-journey-and-stages.md §5.1): speed range, matching ground height, difficulty
## near the target, no repeat of the last three, and a breather after two hard chunks.

const RECENT_LIMIT := 3
const HARD_DIFFICULTY := 4
const HARD_STREAK_LIMIT := 2
const BREATHER := &"breather"

var next_x_px := 0
var last_exit_y := ChunkLayout.GROUND_Y_PX
## Placed chunks as (start x in px) and id, oldest first, for debug display.
var placed_starts := PackedInt32Array()
var placed_ids: Array[StringName] = []

var _rng: RandomNumberGenerator
var _recent: Array[StringName] = []
var _hard_streak := 0
var _layouts: Dictionary[ChunkDefinition, ChunkLayout] = {}


func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng


func choose(pool: Array[ChunkDefinition], speed_px: int, target_difficulty: int) -> ChunkDefinition:
	var fitting := pool.filter(func(c: ChunkDefinition) -> bool: return _fits(c, speed_px))
	assert(not fitting.is_empty(), "no chunk fits speed %d and ground height %d" % [speed_px, last_exit_y])
	var tiers: Array[Array] = [
		fitting.filter(func(c: ChunkDefinition) -> bool: return _suits_level(c, target_difficulty) and c.id not in _recent),
		fitting.filter(func(c: ChunkDefinition) -> bool: return _suits_level(c, target_difficulty)),
		fitting,
	]
	for candidates in tiers:
		if not candidates.is_empty():
			return _weighted_pick(candidates)
	return null


func place(chunk: ChunkDefinition, obstacle_set: ObstacleSet, terrain: Terrain, obstacles: Array[ObstacleState]) -> void:
	var layout := layout_of(chunk)
	var picks: Array[ObstacleData] = []
	for category in layout.slot_categories:
		picks.append(obstacle_set.pick(category, _rng))
	for span in ChunkGround.spans(layout, picks):
		terrain.append_span(next_x_px + span.x, span.y)
	for i in layout.slots.size():
		var slot := layout.slots[i]
		obstacles.append(ObstacleState.new(picks[i], next_x_px + slot.x, slot.y))
	placed_starts.append(next_x_px)
	placed_ids.append(chunk.id)
	next_x_px += layout.width_px
	last_exit_y = layout.exit_y()
	_remember(chunk)


func layout_of(chunk: ChunkDefinition) -> ChunkLayout:
	if not _layouts.has(chunk):
		_layouts[chunk] = ChunkLayout.parse(chunk)
	return _layouts[chunk]


func chunk_id_at(x_px: int) -> StringName:
	var index := placed_starts.bsearch(x_px, false) - 1
	return placed_ids[index] if index >= 0 else &""


func _fits(chunk: ChunkDefinition, speed_px: int) -> bool:
	var layout := layout_of(chunk)
	return layout.errors.is_empty() and chunk.speed_min <= speed_px and speed_px <= chunk.speed_max \
		and layout.entry_y() == last_exit_y


func _suits_level(chunk: ChunkDefinition, target_difficulty: int) -> bool:
	if _hard_streak >= HARD_STREAK_LIMIT:
		return BREATHER in chunk.tags
	return absi(chunk.difficulty - target_difficulty) <= 1


func _weighted_pick(candidates: Array) -> ChunkDefinition:
	var total := 0
	for chunk: ChunkDefinition in candidates:
		total += chunk.weight
	var roll := _rng.randi_range(1, total)
	for chunk: ChunkDefinition in candidates:
		roll -= chunk.weight
		if roll <= 0:
			return chunk
	return candidates[-1]


func _remember(chunk: ChunkDefinition) -> void:
	_recent.append(chunk.id)
	if _recent.size() > RECENT_LIMIT:
		_recent.pop_front()
	_hard_streak = _hard_streak + 1 if chunk.difficulty >= HARD_DIFFICULTY else 0
