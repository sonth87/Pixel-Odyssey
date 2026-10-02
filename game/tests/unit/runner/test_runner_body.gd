extends GdUnitTestSuite

const SPEED := 683
const PIT_START_PX := 100

var _physics: JumpPhysics


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()


func _flat(_x: int) -> int:
	return 0


func _ledge(x: int) -> int:
	return 0 if x < Fixed.from_px(PIT_START_PX) else RunnerBody.NO_GROUND


## Jumps from flat ground holding for `hold_ticks`; returns [apex in subpixels, ticks in the air].
func _jump(hold_ticks: int) -> Array[int]:
	var body := RunnerBody.new(_physics, _flat)
	var apex := 0
	var ticks := 0
	body.step(TickInput.of(true, hold_ticks > 0), SPEED)
	while not body.grounded:
		ticks += 1
		apex = mini(apex, body.y)
		body.step(TickInput.of(false, ticks < hold_ticks), SPEED)
	return [-apex, ticks + 1]


func test_jump_table_matches_the_physics_doc() -> void:
	assert_array(_jump(0)).is_equal([8115, 30])
	assert_array(_jump(4)).is_equal([9726, 33])
	assert_array(_jump(8)).is_equal([11069, 35])
	assert_array(_jump(13)).is_equal([12366, 38])


func test_hold_beyond_the_limit_adds_nothing() -> void:
	assert_array(_jump(30)).is_equal(_jump(13))


func test_runs_without_input_and_stays_grounded() -> void:
	var body := RunnerBody.new(_physics, _flat)
	for i in 60:
		body.step(TickInput.of(false, false), SPEED)
	assert_bool(body.grounded).is_true()
	assert_int(body.x).is_equal(SPEED * 60)


func _walk_off_ledge_then_press(air_ticks_before_press: int) -> RunnerBody:
	var body := RunnerBody.new(_physics, _ledge)
	body.death_y = Fixed.from_px(64)
	while body.grounded:
		body.step(TickInput.of(false, false), SPEED)
	for i in air_ticks_before_press - 1:
		body.step(TickInput.of(false, false), SPEED)
	body.step(TickInput.of(true, true), SPEED)
	return body


func test_coyote_time_allows_a_late_jump() -> void:
	var body := _walk_off_ledge_then_press(_physics.coyote_ticks)
	assert_int(body.vy).is_less(0)


func test_after_coyote_time_the_runner_falls() -> void:
	var body := _walk_off_ledge_then_press(_physics.coyote_ticks + 2)
	assert_int(body.vy).is_greater(0)


func test_jump_buffer_jumps_on_landing() -> void:
	var body := RunnerBody.new(_physics, _flat)
	body.step(TickInput.of(true, false), SPEED)
	while body.vy < 0 or body.y < -Fixed.from_px(4):
		body.step(TickInput.of(false, false), SPEED)
	body.step(TickInput.of(true, false), SPEED)
	while not body.grounded:
		body.step(TickInput.of(false, false), SPEED)
	body.step(TickInput.of(false, false), SPEED)
	assert_int(body.vy).is_less(0)


func test_falling_into_a_pit_kills() -> void:
	var body := RunnerBody.new(_physics, _ledge)
	body.death_y = Fixed.from_px(48)
	for i in 120:
		body.step(TickInput.of(false, false), SPEED)
	assert_bool(body.dead).is_true()
