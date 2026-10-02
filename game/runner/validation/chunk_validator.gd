class_name ChunkValidator
## Proves a chunk can be cleared in the normal state, without stomps, shields or items, at its minimum,
## middle and maximum speeds, and checks the static fairness rules
## (docs/05-technical/05-physics-collision-generation.md §6–7). Returns a list of errors; empty means valid.

const BUFFER_COLUMNS := 6
const MAX_APPROACH_SPEED := 365.0
const HOLD_OPTIONS: Array[int] = [0, 4, 8, 13]
const RUNWAY_PX := 160
const MAX_AIR_TICKS := 240


static func validate(chunk: ChunkDefinition, obstacle_set: ObstacleSet, physics: JumpPhysics) -> Array[String]:
	var layout := ChunkLayout.parse(chunk)
	var errors: Array[String] = []
	errors.append_array(layout.errors)
	if not errors.is_empty():
		return errors
	_check_buffers(layout, errors)
	_check_obstacles(chunk, layout, obstacle_set, errors)
	if not errors.is_empty():
		return errors
	for picks in _variant_combinations(layout, obstacle_set):
		for speed: float in [chunk.speed_min, (chunk.speed_min + chunk.speed_max) / 2.0, chunk.speed_max]:
			if not ChunkPathSearch.new(layout, picks, physics, Fixed.velocity(speed)).passable():
				errors.append("%s: not passable at %d px/s with %s" % [chunk.id, int(speed), _describe(picks)])
	return errors


static func _check_buffers(layout: ChunkLayout, errors: Array[String]) -> void:
	var columns := layout.column_ground.size()
	if columns < BUFFER_COLUMNS * 2:
		errors.append("chunk shorter than its two buffer zones")
		return
	for column in BUFFER_COLUMNS:
		if layout.column_ground[column] != layout.entry_y():
			errors.append("entry buffer is not flat at column %d" % column)
		if layout.column_ground[columns - 1 - column] != layout.exit_y():
			errors.append("exit buffer is not flat at column %d" % (columns - 1 - column))
	for slot in layout.slots:
		if slot.z < BUFFER_COLUMNS or slot.z >= columns - BUFFER_COLUMNS:
			errors.append("obstacle inside a buffer zone at column %d" % slot.z)


static func _check_obstacles(chunk: ChunkDefinition, layout: ChunkLayout, obstacle_set: ObstacleSet,
		errors: Array[String]) -> void:
	if chunk.speed_max > MAX_APPROACH_SPEED:
		errors.append("speed_max %d exceeds the approach limit" % int(chunk.speed_max))
	for category in layout.slot_categories:
		var variants := obstacle_set.variants(category)
		if variants.is_empty():
			errors.append("obstacle set has nothing for %s" % category)
		for data in variants:
			if data.solid_top and not data.behavior is StaticBehavior:
				errors.append("%s: solid_top requires a static behavior" % data.id)
			if chunk.speed_max + data.behavior.approach_speed() > MAX_APPROACH_SPEED:
				errors.append("%s approaches faster than %d px/s at speed_max" % [data.id, int(MAX_APPROACH_SPEED)])


## Every variant of each category once, the other categories using their first variant.
static func _variant_combinations(layout: ChunkLayout, obstacle_set: ObstacleSet) -> Array[Dictionary]:
	var base := {}
	for category in layout.slot_categories:
		base[category] = obstacle_set.variants(category)[0]
	var combos: Array[Dictionary] = [base]
	for category: StringName in base:
		for data: ObstacleData in obstacle_set.variants(category).slice(1):
			var combo := base.duplicate()
			combo[category] = data
			combos.append(combo)
	return combos


static func _describe(picks: Dictionary) -> String:
	var names: Array[String] = []
	for category: StringName in picks:
		names.append(String((picks[category] as ObstacleData).id))
	return ", ".join(names) if not names.is_empty() else "no obstacles"
