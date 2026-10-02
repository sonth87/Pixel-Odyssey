extends GdUnitTestSuite

const GROUND := 148

var _physics: JumpPhysics
var _terrain: Terrain


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_terrain = Terrain.new()
	_terrain.append_span(-1000, GROUND)


func _enemy(stompable: bool) -> ObstacleData:
	var data := ObstacleData.new()
	data.id = &"test_enemy"
	data.category = &"enemy_static"
	data.hitbox = Rect2i(-5, -20, 10, 20)
	data.stompable = stompable
	return data


func _body_at(x_px: int, feet_px: int, vy: int) -> RunnerBody:
	var body := RunnerBody.new(_physics, _terrain)
	body.x = Fixed.from_px(x_px)
	body.y = Fixed.from_px(feet_px)
	body.vy = vy
	body.grounded = vy == 0
	return body


func test_running_into_an_enemy_kills() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(true), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y)
	assert_int(body.death).is_equal(RunnerBody.Death.CONTACT)


func test_falling_onto_a_stompable_enemy_stomps_and_bounces() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(true), 100, GROUND)]
	var body := _body_at(100, GROUND - 18, 300)
	var stomped := CollisionResolver.resolve(body, obstacles, Fixed.from_px(GROUND - 21))
	assert_int(stomped.size()).is_equal(1)
	assert_bool(obstacles[0].defeated).is_true()
	assert_bool(body.is_dead()).is_false()
	assert_int(body.vy).is_equal(-_physics.stomp_velocity)


func test_falling_onto_an_unstompable_obstacle_kills() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(false), 100, GROUND)]
	var body := _body_at(100, GROUND - 18, 300)
	CollisionResolver.resolve(body, obstacles, Fixed.from_px(GROUND - 21))
	assert_int(body.death).is_equal(RunnerBody.Death.CONTACT)


func test_charger_triggers_by_distance_not_time() -> void:
	var data := _enemy(true)
	var behavior := ChargerBehavior.new()
	behavior.trigger_distance_px = 200
	behavior.telegraph_time = 0.25
	data.behavior = behavior
	var charger := ObstacleState.new(data, 400, GROUND)
	for i in 600:
		charger.step(Fixed.from_px(150))
	assert_int(charger.x).is_equal(Fixed.from_px(400))
	charger.step(Fixed.from_px(200))
	assert_int(charger.motion.phase).is_equal(ObstacleMotion.Phase.TELEGRAPH)
	for i in Fixed.ticks(0.25) + 1:
		charger.step(Fixed.from_px(200))
	assert_int(charger.x).is_less(Fixed.from_px(400))
