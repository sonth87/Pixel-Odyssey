extends GdUnitTestSuite

const GROUND := 148
const SPEED := 683

var _physics: JumpPhysics


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()


func _terrain(spans: Array[Vector2i]) -> Terrain:
	var terrain := Terrain.new()
	for span in spans:
		terrain.append_span(span.x, span.y)
	return terrain


func _runner(terrain: Terrain) -> RunnerBody:
	var body := RunnerBody.new(_physics, terrain)
	body.y = Fixed.from_px(GROUND)
	body.death_y = Fixed.from_px(196)
	return body


func _run(body: RunnerBody, ticks: int) -> void:
	for i in ticks:
		body.step(TickInput.of(false, false), SPEED)


func test_terrain_queries() -> void:
	var terrain := _terrain([Vector2i(0, GROUND), Vector2i(100, Terrain.NO_GROUND), Vector2i(140, 140)])
	assert_int(terrain.ground_at(-1)).is_equal(Terrain.NO_GROUND)
	assert_int(terrain.ground_at(99)).is_equal(GROUND)
	assert_int(terrain.ground_at(120)).is_equal(Terrain.NO_GROUND)
	assert_int(terrain.highest_in(90, 150)).is_equal(140)
	assert_int(terrain.highest_in(100, 139)).is_equal(Terrain.NO_GROUND)


func test_small_step_is_climbed_without_jumping() -> void:
	var body := _runner(_terrain([Vector2i(-50, GROUND), Vector2i(60, GROUND - 4)]))
	_run(body, 120)
	assert_bool(body.is_dead()).is_false()
	assert_int(body.y).is_equal(Fixed.from_px(GROUND - 4))


func test_running_into_a_high_step_is_a_wall_death() -> void:
	var body := _runner(_terrain([Vector2i(-50, GROUND), Vector2i(60, GROUND - 8)]))
	_run(body, 120)
	assert_int(body.death).is_equal(RunnerBody.Death.WALL)


func test_corner_correction_lifts_a_runner_up_to_6_px_short() -> void:
	var terrain := _terrain([Vector2i(-50, GROUND), Vector2i(20, GROUND - 24)])
	var body := _runner(terrain)
	body.grounded = false
	body.y = Fixed.from_px(GROUND - 18)
	body.vy = 0
	body.x = Fixed.from_px(14)
	body.step(TickInput.of(false, false), Fixed.from_px(2))
	assert_bool(body.is_dead()).is_false()
	assert_int(body.y).is_equal(Fixed.from_px(GROUND - 24))


func test_falling_into_a_pit_against_its_far_wall_dies() -> void:
	var body := _runner(_terrain([Vector2i(-50, GROUND), Vector2i(40, Terrain.NO_GROUND), Vector2i(64, GROUND)]))
	_run(body, 200)
	assert_bool(body.is_dead()).is_true()
	assert_int(body.x).is_less(Fixed.from_px(80))
