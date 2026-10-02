extends GdUnitTestSuite
## M1-09's "runs for 10 minutes without error" is split in two: spawning/terrain over a very long distance
## (fully deterministic, checked here directly) and a player actually surviving that long (needs a bot
## skilled enough to clear every chunk, which does not exist yet — out of scope for the greybox milestone).

const ISLAND := "res://content/common/greybox/greybox_island.tres"
## 10 minutes at a representative ~220 px/s.
const TEN_MINUTE_DISTANCE_PX := 220 * 600


func test_spawner_fills_ten_minutes_of_distance_without_error() -> void:
	var island: IslandData = load(ISLAND)
	var segment := island.segments[0]
	var spawner := ChunkSpawner.new(RngStreams.new(99).stream(&"chunks"))
	var terrain := Terrain.new()
	var obstacles: Array[ObstacleState] = []
	var chunk_count := 0
	while spawner.next_x_px < TEN_MINUTE_DISTANCE_PX:
		var chunk := spawner.choose(segment.chunk_pool, 220, 3)
		assert_object(chunk).is_not_null()
		spawner.place(chunk, segment.obstacle_set, terrain, obstacles)
		chunk_count += 1
		terrain.drop_before(spawner.next_x_px - 160)
		while obstacles.size() > 0 and obstacles[0].x < Fixed.from_px(spawner.next_x_px - 160):
			obstacles.pop_front()
	assert_int(chunk_count).is_greater(300)
	assert_int(terrain.span_count()).is_less(50)
	assert_int(obstacles.size()).is_less(20)


func test_invincible_revive_moves_past_the_hazard_and_keeps_the_run_going() -> void:
	var physics := RunnerPhysicsConfig.new().compile()
	var island: IslandData = load(ISLAND)
	var run := RunSimulation.new(physics, island, RngStreams.new(1))
	var revives := 0
	for tick in 3000:
		run.step(TickInput.of(false, false))
		if run.body.is_dead():
			revives += 1
			var before_x := run.body.x
			run.body.death = RunnerBody.Death.NONE
			run.body.vy = 0
			run.body.x += Fixed.from_px(64)
			var ground := run.terrain.ground_at(run.body.x)
			if ground != Terrain.NO_GROUND:
				run.body.y = ground
				run.body.grounded = true
			assert_int(run.body.x).is_greater(before_x)
	assert_int(revives).is_greater(0)
	assert_bool(run.body.is_dead()).is_false()
