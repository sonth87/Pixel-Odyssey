extends GdUnitTestSuite
## Covers the interaction matrix of docs/01-game-design/09-interaction-rules.md §4: normal contact and
## stomp (M1), plus shield, i-frames, destroy-on-contact, phase-through and transform (M2).

const GROUND := 148

var _physics: JumpPhysics
var _terrain: Terrain


func before_test() -> void:
	_physics = RunnerPhysicsConfig.new().compile()
	_terrain = Terrain.new()
	_terrain.append_span(-1000, GROUND)


func _obstacle(category: StringName, stompable: bool, destructible := true) -> ObstacleData:
	var data := ObstacleData.new()
	data.id = &"test_obstacle"
	data.category = category
	data.hitbox = Rect2i(-5, -20, 10, 20)
	data.stompable = stompable
	data.destructible = destructible
	return data


func _enemy(stompable: bool) -> ObstacleData:
	return _obstacle(&"enemy_static", stompable)


func _body_at(x_px: int, feet_px: int, vy: int) -> RunnerBody:
	var body := RunnerBody.new(_physics, _terrain)
	body.x = Fixed.from_px(x_px)
	body.y = Fixed.from_px(feet_px)
	body.vy = vy
	body.grounded = vy == 0
	return body


func _host(passive: Array[EffectData] = []) -> EffectHost:
	return EffectHost.new(passive)


func test_running_into_an_enemy_kills() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(true), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, _host())
	assert_int(body.death).is_equal(RunnerBody.Death.CONTACT)


func test_falling_onto_a_stompable_enemy_stomps_and_bounces() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(true), 100, GROUND)]
	var body := _body_at(100, GROUND - 18, 300)
	var stomped := CollisionResolver.resolve(body, obstacles, Fixed.from_px(GROUND - 21), _host())
	assert_int(stomped.size()).is_equal(1)
	assert_bool(obstacles[0].defeated).is_true()
	assert_bool(body.is_dead()).is_false()
	assert_int(body.vy).is_equal(-_physics.stomp_velocity)


func test_falling_onto_an_unstompable_obstacle_kills() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(false), 100, GROUND)]
	var body := _body_at(100, GROUND - 18, 300)
	CollisionResolver.resolve(body, obstacles, Fixed.from_px(GROUND - 21), _host())
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


## --- M2: shield ---

func test_shield_blocks_contact_and_destroys_a_destructible_obstacle() -> void:
	var host := _host()
	host.add_shield(1)
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_true()
	assert_bool(host.has_shield()).is_false()


func test_shield_against_an_indestructible_hazard_is_not_destroyed_but_blocks() -> void:
	var host := _host()
	host.add_shield(1)
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_obstacle(&"hazard", false, false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_false()
	assert_bool(host.has_shield()).is_false()


func test_at_most_one_shield_is_spent_per_tick() -> void:
	var host := _host()
	host.add_shield(2)
	var obstacles: Array[ObstacleState] = [
		ObstacleState.new(_enemy(false), 100, GROUND), ObstacleState.new(_enemy(false), 103, GROUND)]
	var body := _body_at(96, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(host.has_shield()).is_true()  # one of the two charges is still left


## --- M2: i-frames ---

func test_iframes_ignore_contact_entirely() -> void:
	var host := _host()
	host.add_shield(1)
	host.break_shield()  # grants i-frames without needing a real hit in this test
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_false()


## --- M2: destroy-on-contact / phase-through (devil-fruit-style effects, independent of any character) ---

func _destroy(filter: Array[StringName]) -> EffectHost:
	var effect := DestroyOnContactEffect.new()
	effect.filter = filter
	return _host([effect] as Array[EffectData])


func _phase(filter: Array[StringName]) -> EffectHost:
	var effect := PhaseThroughEffect.new()
	effect.filter = filter
	return _host([effect] as Array[EffectData])


func test_destroy_on_contact_matching_filter_destroys_and_survives() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_enemy(false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, _destroy([&"enemy_*"]))
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_true()


func test_destroy_on_contact_outside_filter_still_kills() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_obstacle(&"hazard", false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, _destroy([&"enemy_*"]))
	assert_int(body.death).is_equal(RunnerBody.Death.CONTACT)


func test_phase_through_matching_filter_passes_without_destroying() -> void:
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_obstacle(&"hazard", false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, _phase([&"hazard"]))
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_false()


func test_rush_destroys_or_phases_through_any_category() -> void:
	var host := _host([RushEffect.new()] as Array[EffectData])
	var obstacles: Array[ObstacleState] = [
		ObstacleState.new(_obstacle(&"hazard", false, false), 100, GROUND),
		ObstacleState.new(_enemy(false), 103, GROUND)]
	var body := _body_at(96, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_false()  # hazard: not destructible -> phased through
	assert_bool(obstacles[1].defeated).is_true()   # enemy: destructible -> destroyed


## --- M2: transform (a size_mult + destroy_on_contact(*) form, as every transform must be per E2) ---

func _gear4_host() -> EffectHost:
	var size := SizeMultEffect.new()
	size.factor = 1.5
	var destroy := DestroyOnContactEffect.new()
	destroy.filter = ObstacleFilter.ALL
	var host := _host()
	host.enter_transform(&"gear4", [size, destroy] as Array[EffectData], 8.0)
	for i in EffectHost.ENTER_TICKS:
		host.step()
	return host


func test_active_transform_destroys_any_obstacle_on_contact() -> void:
	var host := _gear4_host()
	var obstacles: Array[ObstacleState] = [ObstacleState.new(_obstacle(&"hazard", false), 100, GROUND)]
	var body := _body_at(92, GROUND, 0)
	CollisionResolver.resolve(body, obstacles, body.y, host)
	assert_bool(body.is_dead()).is_false()
	assert_bool(obstacles[0].defeated).is_true()


func test_transform_still_dies_to_a_pit_or_wall() -> void:
	# Transform alone grants no PIT/WALL protection (interaction rules §2) — only rush/bridge_gaps would.
	var host := _gear4_host()
	assert_bool(host.modifiers().rush).is_false()
