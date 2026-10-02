extends GdUnitTestSuite

const FLAT := "########################################"
const EMPTY := "........................................"
const GREYBOX_SET := "res://content/common/greybox/greybox_obstacles.tres"

var _physics: JumpPhysics
var _set: ObstacleSet


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_set = load(GREYBOX_SET)


func _chunk(rows: Array[String], speed_max := 260.0) -> ChunkDefinition:
	var chunk := ChunkDefinition.new()
	chunk.id = &"test"
	chunk.speed_max = speed_max
	chunk.layout = PackedStringArray(rows)
	return chunk


func test_layout_reads_ground_pits_and_slots() -> void:
	var layout := ChunkLayout.parse(_chunk([EMPTY, "...........#.......l....................", "######.....#############################"]))
	assert_array(layout.errors).is_empty()
	assert_int(layout.width_px).is_equal(320)
	assert_int(layout.column_ground[0]).is_equal(148)
	assert_int(layout.column_ground[6]).is_equal(Terrain.NO_GROUND)
	assert_int(layout.column_ground[11]).is_equal(140)
	assert_int(layout.slots[0].x).is_equal(19 * 8 + 4)
	assert_str(String(layout.slot_categories[0])).is_equal("ground_low")


func test_valid_chunk_passes() -> void:
	var errors := ChunkValidator.validate(_chunk([EMPTY, "...................l....................", FLAT]), _set, _physics)
	assert_array(errors).is_empty()


func test_pit_wider_than_any_jump_fails() -> void:
	var rows: Array[String] = [EMPTY, "########...............#################"]
	var errors := ChunkValidator.validate(_chunk(rows), _set, _physics)
	assert_array(errors).is_not_empty()


func test_wall_higher_than_any_jump_fails() -> void:
	var rows: Array[String] = ["..............##########................", "..............##########................",
		"..............##########................", "..............##########................",
		"..............##########................", "..............##########................",
		"..............##########................", FLAT]
	assert_array(ChunkValidator.validate(_chunk(rows), _set, _physics)).is_not_empty()


func test_obstacle_inside_the_buffer_zone_fails() -> void:
	var rows: Array[String] = [EMPTY, "..l.....................................", FLAT]
	assert_array(ChunkValidator.validate(_chunk(rows), _set, _physics)).is_not_empty()


func test_charger_too_fast_for_speed_max_fails() -> void:
	var rows: Array[String] = [EMPTY, "..............................c.........", FLAT]
	assert_array(ChunkValidator.validate(_chunk(rows, 340.0), _set, _physics)).is_not_empty()


func test_greybox_island_chunks_are_all_valid() -> void:
	var island: IslandData = load("res://content/common/greybox/greybox_island.tres")
	for chunk in island.segments[0].chunk_pool:
		assert_array(ChunkValidator.validate(chunk, island.segments[0].obstacle_set, _physics)).is_empty()
