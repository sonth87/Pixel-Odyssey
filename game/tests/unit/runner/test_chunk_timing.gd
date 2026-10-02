extends GdUnitTestSuite

const SET_PATH := "res://content/common/greybox/greybox_obstacles.tres"

var _physics: JumpPhysics
var _set: ObstacleSet


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_set = load(SET_PATH)


func _chunk(rows: Array[String], speed_max := 260.0) -> ChunkDefinition:
	var chunk := ChunkDefinition.new()
	chunk.id = &"timing_test"
	chunk.speed_max = speed_max
	chunk.layout = PackedStringArray(rows)
	return chunk


func test_flat_chunk_has_no_jump_events() -> void:
	var layout := ChunkLayout.parse(_chunk(["........................................",
		"........................................", "........................................",
		"########################################"]))
	var search := ChunkPathSearch.new(layout, {}, _physics, Fixed.velocity(200.0))
	assert_array(search.find_path()).is_empty()


func test_single_gap_gives_a_generous_window() -> void:
	## A 24 px gap turns out to be crossable by momentum alone without jumping at this speed, so this
	## uses a wider one (40 px) that genuinely forces a jump.
	var layout := ChunkLayout.parse(_chunk([
		"........................................", "........................................",
		"........................................", "###################.....################"]))
	var search := ChunkPathSearch.new(layout, {}, _physics, Fixed.velocity(200.0))
	var path := search.find_path()
	assert_int(path.size()).is_equal(1)
	assert_int(search.timing_window(path[0])).is_greater_equal(ChunkValidator.MIN_TIMING_WINDOW)


func test_validator_flags_a_too_tight_timing_window() -> void:
	## A gap this close to the maximum distance 300 px/s can clear only works with near-maximum hold,
	## which leaves almost no room to press earlier than the one tick that was actually used. speed_min is
	## pinned to the same value so the passability loop (which must pass first) checks only this speed.
	var chunk := _chunk(["........................................", "........................................",
		"........................................", "########....................############"], 300.0)
	chunk.speed_min = 300.0
	var errors := ChunkValidator.validate(chunk, _set, _physics)
	var tight := errors.any(func(e: String) -> bool: return e.contains("tick(s) to press jump"))
	assert_bool(tight).is_true()


func test_greybox_chunks_have_a_comfortable_timing_window() -> void:
	var island: IslandData = load("res://content/common/greybox/greybox_island.tres")
	for chunk in island.segments[0].chunk_pool:
		assert_array(ChunkValidator.validate(chunk, island.segments[0].obstacle_set, _physics)).is_empty()
