extends GdUnitTestSuite


func _speed(factor: float) -> SpeedMultEffect:
	var e := SpeedMultEffect.new()
	e.factor = factor
	return e


func _destroy(filter: Array[StringName]) -> DestroyOnContactEffect:
	var e := DestroyOnContactEffect.new()
	e.filter = filter
	return e


func test_defaults_are_neutral() -> void:
	var m := Modifiers.combine([])
	assert_float(m.speed_mult).is_equal(1.0)
	assert_float(m.jump_mult).is_equal(1.0)
	assert_float(m.size_mult).is_equal(1.0)
	assert_bool(m.rush).is_false()


func test_same_type_multiplies_then_clamps() -> void:
	var m := Modifiers.combine([_speed(1.3), _speed(1.3)] as Array[EffectData])
	assert_float(m.speed_mult).is_equal(Modifiers.MAX_SPEED_MULT)


func test_destroy_filters_from_multiple_effects_accumulate() -> void:
	var m := Modifiers.combine([_destroy([&"enemy_*"]), _destroy([&"hazard"])] as Array[EffectData])
	assert_bool(m.destroys(&"enemy_static")).is_true()
	assert_bool(m.destroys(&"hazard")).is_true()
	assert_bool(m.destroys(&"ground_tall")).is_false()


func test_wildcard_filter_matches_everything() -> void:
	var m := Modifiers.combine([_destroy(ObstacleFilter.ALL)] as Array[EffectData])
	assert_bool(m.destroys(&"anything")).is_true()
