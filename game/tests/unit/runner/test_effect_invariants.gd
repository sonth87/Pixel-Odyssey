extends GdUnitTestSuite


func test_speed_above_1_without_rush_fails_e1() -> void:
	var speed := SpeedMultEffect.new()
	speed.factor = 1.3
	var errors := EffectInvariants.check([speed] as Array[EffectData])
	assert_bool(errors.any(func(e: String) -> bool: return e.begins_with("E1"))).is_true()


func test_speed_above_1_with_rush_passes() -> void:
	var speed := SpeedMultEffect.new()
	speed.factor = 1.3
	var errors := EffectInvariants.check([speed, RushEffect.new()] as Array[EffectData])
	assert_array(errors).is_empty()


func test_size_above_1_without_destroy_all_fails_e2() -> void:
	var size := SizeMultEffect.new()
	size.factor = 1.5
	var errors := EffectInvariants.check([size] as Array[EffectData])
	assert_bool(errors.any(func(e: String) -> bool: return e.begins_with("E2"))).is_true()


func test_size_above_1_with_destroy_all_passes() -> void:
	var size := SizeMultEffect.new()
	size.factor = 1.5
	var destroy := DestroyOnContactEffect.new()
	destroy.filter = ObstacleFilter.ALL
	assert_array(EffectInvariants.check([size, destroy] as Array[EffectData])).is_empty()


func test_transform_form_without_destroy_all_fails_e2() -> void:
	assert_array(EffectInvariants.check([] as Array[EffectData], true)).is_not_empty()


func test_jump_above_1_without_air_hazard_coverage_fails_e3() -> void:
	var jump := JumpMultEffect.new()
	jump.factor = 1.3
	var destroy := DestroyOnContactEffect.new()
	destroy.filter = [&"enemy_*"]
	var errors := EffectInvariants.check([jump, destroy] as Array[EffectData])
	assert_bool(errors.any(func(e: String) -> bool: return e.begins_with("E3"))).is_true()


func test_jump_above_1_with_air_hazard_coverage_passes() -> void:
	var jump := JumpMultEffect.new()
	jump.factor = 1.3
	var destroy := DestroyOnContactEffect.new()
	destroy.filter = [&"air", &"falling", &"projectile"]
	assert_array(EffectInvariants.check([jump, destroy] as Array[EffectData])).is_empty()


func test_any_mult_below_1_fails_e4() -> void:
	var speed := SpeedMultEffect.new()
	speed.factor = 0.5
	var errors := EffectInvariants.check([speed] as Array[EffectData])
	assert_bool(errors.any(func(e: String) -> bool: return e.begins_with("E4"))).is_true()
