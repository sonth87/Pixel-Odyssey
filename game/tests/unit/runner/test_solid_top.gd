extends GdUnitTestSuite

const SET := "res://content/common/greybox/greybox_obstacles.tres"
const SPEED := 768

var _physics: JumpPhysics
var _set: ObstacleSet


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_set = load(SET)


func _world(category: StringName) -> Array:
	var chunk := ChunkDefinition.new()
	chunk.layout = PackedStringArray([
		"...................%s...................." % ChunkLayout.CATEGORIES.find_key(category),
		"########################################"])
	var layout := ChunkLayout.parse(chunk)
	var data := _set.variants(category)[0]
	var terrain := Terrain.new()
	terrain.append_span(-500, 148)
	for span in ChunkGround.spans(layout, [data] as Array[ObstacleData]):
		terrain.append_span(span.x, span.y)
	var obstacles: Array[ObstacleState] = [ObstacleState.new(data, layout.slots[0].x, layout.slots[0].y)]
	var body := RunnerBody.new(_physics, terrain)
	body.y = Fixed.from_px(148)
	body.death_y = Fixed.from_px(196)
	return [body, obstacles]


## Jumps at `jump_tick` holding `hold` ticks and runs 240 ticks; returns [body, landed on top of the obstacle].
func _run(world: Array, jump_tick: int, hold: int) -> Array:
	var body: RunnerBody = world[0]
	var obstacles: Array[ObstacleState] = world[1]
	var landed_high := false
	for t in 240:
		var feet := body.y
		body.step(TickInput.of(t == jump_tick, t >= jump_tick and t < jump_tick + hold), SPEED)
		CollisionResolver.resolve(body, obstacles, feet)
		landed_high = landed_high or (body.grounded and body.y < Fixed.from_px(148))
		if body.is_dead():
			break
	return [body, landed_high]


func _first_jump_that_lands_on_top(category: StringName) -> RunnerBody:
	for jump_tick in range(0, 60):
		var result := _run(_world(category), jump_tick, 4)
		if result[1]:
			return result[0]
	return null


func test_landing_on_a_crate_is_safe() -> void:
	var body := _first_jump_that_lands_on_top(&"ground_low")
	assert_object(body).is_not_null()
	assert_bool(body.is_dead()).is_false()


func test_running_into_a_crate_side_is_a_wall_death() -> void:
	var body: RunnerBody = _run(_world(&"ground_low"), 1000, 0)[0]
	assert_int(body.death).is_equal(RunnerBody.Death.WALL)


func test_touching_a_spiked_obstacle_from_above_kills() -> void:
	var deaths := 0
	for jump_tick in range(0, 60):
		var body: RunnerBody = _run(_world(&"ground_tall"), jump_tick, 13)[0]
		if body.death == RunnerBody.Death.CONTACT:
			deaths += 1
	assert_int(deaths).is_greater(0)


func test_validator_rejects_a_moving_solid_top_obstacle() -> void:
	var moving: ObstacleData = _set.variants(&"enemy_moving")[0].duplicate()
	moving.solid_top = true
	var custom := ObstacleSet.new()
	custom.obstacles = [moving] as Array[ObstacleData]
	var chunk := ChunkDefinition.new()
	chunk.layout = PackedStringArray(["..............................c.........", "########################################"])
	assert_array(ChunkValidator.validate(chunk, custom, _physics)).is_not_empty()
