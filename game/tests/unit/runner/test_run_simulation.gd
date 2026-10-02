extends GdUnitTestSuite

const ISLAND := "res://content/common/greybox/greybox_island.tres"

var _physics: JumpPhysics
var _island: IslandData


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_island = load(ISLAND)


func _scripted_input(tick: int) -> TickInput:
	var phase := tick % 50
	return TickInput.of(phase == 0, phase < 6)


func _play(seed_value: int, ticks: int, inputs: Callable) -> RunSimulation:
	var run := RunSimulation.new(_physics, _island, RngStreams.new(seed_value))
	for tick in ticks:
		run.step(inputs.call(tick))
	return run


func _chunk_ids(run: RunSimulation) -> Array[StringName]:
	return run.spawner.placed_ids


func test_same_seed_and_input_give_the_same_run() -> void:
	var a := _play(11, 900, _scripted_input)
	var b := _play(11, 900, _scripted_input)
	assert_int(a.body.x).is_equal(b.body.x)
	assert_int(a.body.y).is_equal(b.body.y)
	assert_int(a.tick).is_equal(b.tick)
	assert_int(a.body.death).is_equal(b.body.death)
	assert_array(_chunk_ids(a)).is_equal(_chunk_ids(b))


func test_chunk_sequence_depends_only_on_seed_not_on_input() -> void:
	var idle := RunSimulation.new(_physics, _island, RngStreams.new(5))
	var jumpy := _play(5, 300, _scripted_input)
	var common := mini(idle.spawner.placed_ids.size(), jumpy.spawner.placed_ids.size())
	assert_array(idle.spawner.placed_ids.slice(0, common)).is_equal(jumpy.spawner.placed_ids.slice(0, common))


func test_replaying_a_recording_reproduces_the_run() -> void:
	var original := _play(23, 1200, _scripted_input)
	var replay := original.recording.replay()
	var copy := _play(23, 1200, func(tick: int) -> TickInput: return replay.next(tick))
	assert_int(copy.body.x).is_equal(original.body.x)
	assert_int(copy.body.death).is_equal(original.body.death)
	assert_int(copy.tick).is_equal(original.tick)


func test_never_jumping_ends_the_run() -> void:
	var run := _play(3, 3000, func(_tick: int) -> TickInput: return TickInput.of(false, false))
	assert_bool(run.body.is_dead()).is_true()


func test_speed_ramps_from_start_to_end_of_island() -> void:
	var run := RunSimulation.new(_physics, _island, RngStreams.new(1))
	assert_int(run.speed_px_per_second(Fixed.from_px(RunSimulation.PLAYER_START_PX))).is_equal(140)
	var far := Fixed.from_px(RunSimulation.PLAYER_START_PX + _island.length_m * 16)
	assert_int(run.speed_px_per_second(far)).is_equal(260)


func test_breather_follows_two_hard_chunks() -> void:
	var spawner := ChunkSpawner.new(RngStreams.new(9).stream(&"chunks"))
	var pool := _island.segments[0].chunk_pool
	var hard_in_a_row := 0
	for i in 200:
		var chunk := spawner.choose(pool, 220, 4)
		spawner.place(chunk, _island.segments[0].obstacle_set, Terrain.new(), [] as Array[ObstacleState])
		assert_int(hard_in_a_row).is_less_equal(2)
		hard_in_a_row = hard_in_a_row + 1 if chunk.difficulty >= 4 else 0
