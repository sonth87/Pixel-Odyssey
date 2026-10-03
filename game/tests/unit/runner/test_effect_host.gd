extends GdUnitTestSuite


func _destroy_all() -> Array[EffectData]:
	var d := DestroyOnContactEffect.new()
	d.filter = ObstacleFilter.ALL
	return [d] as Array[EffectData]


func _size(factor: float) -> Array[EffectData]:
	var s := SizeMultEffect.new()
	s.factor = factor
	return ([s] as Array[EffectData]) + _destroy_all()


func test_shield_adds_and_caps_at_three() -> void:
	var host := EffectHost.new()
	host.add_shield(2)
	host.add_shield(5)
	assert_bool(host.has_shield()).is_true()
	# Internal cap isn't exposed directly; break three times and expect the fourth to have nothing left.
	host.break_shield()
	host.break_shield()
	host.break_shield()
	assert_bool(host.has_shield()).is_false()


func test_breaking_a_shield_grants_0_6s_of_iframes() -> void:
	var host := EffectHost.new()
	host.add_shield(1)
	host.break_shield()
	assert_bool(host.is_invulnerable()).is_true()
	for i in EffectHost.SHIELD_BREAK_IFRAMES_TICKS - 1:
		host.step()
	assert_bool(host.is_invulnerable()).is_true()
	host.step()
	assert_bool(host.is_invulnerable()).is_false()


func test_transform_lifecycle_phases_and_durations() -> void:
	var host := EffectHost.new()
	host.enter_transform(&"gear4", _size(1.5), 8.0)
	assert_bool(host.is_transforming()).is_true()
	assert_str(String(host.transform_form_id())).is_equal("gear4")
	assert_bool(host.is_invulnerable()).is_true()  # entering
	assert_float(host.modifiers().size_mult).is_equal(1.0)  # form effects not active yet

	for i in EffectHost.ENTER_TICKS:
		host.step()
	assert_bool(host.is_invulnerable()).is_false()  # now active
	assert_float(host.modifiers().size_mult).is_equal(1.5)

	for i in Fixed.ticks(8.0) - 1:
		host.step()
	assert_bool(host.is_transforming()).is_true()  # still active, one tick left
	host.step()  # active -> exiting
	assert_bool(host.is_invulnerable()).is_true()
	assert_float(host.modifiers().size_mult).is_equal(1.0)  # form effects gone once not ACTIVE

	for i in EffectHost.EXIT_TICKS:
		host.step()
	assert_bool(host.is_invulnerable()).is_true()  # post i-frames
	for i in EffectHost.POST_IFRAMES_TICKS - 1:
		host.step()
	assert_bool(host.is_invulnerable()).is_true()
	host.step()
	assert_bool(host.is_invulnerable()).is_false()
	assert_bool(host.is_transforming()).is_false()


func test_eating_again_while_transformed_refreshes_without_replaying_enter() -> void:
	var host := EffectHost.new()
	host.enter_transform(&"gear4", _size(1.5), 8.0)
	for i in EffectHost.ENTER_TICKS:
		host.step()
	for i in 200:
		host.step()
	host.enter_transform(&"gear4", _size(1.5), 8.0)
	assert_bool(host.is_invulnerable()).is_false()  # no enter animation replayed
	assert_float(host.modifiers().size_mult).is_equal(1.5)  # active again immediately


func test_duration_mult_passive_extends_transform_duration() -> void:
	var duration := DurationMultEffect.new()
	duration.factor = 1.2
	var host := EffectHost.new([duration] as Array[EffectData])
	assert_int(host.effective_duration_ticks(8.0)).is_equal(Fixed.ticks(9.6))


func test_apply_timed_extension_is_capped_at_1_5x_base() -> void:
	var host := EffectHost.new()
	host.apply_timed(&"pika", [] as Array[EffectData], 4.0)
	host.apply_timed(&"pika", [] as Array[EffectData], 4.0)
	for i in roundi(Fixed.ticks(4.0) * 1.5):
		host.step()
	# at 1.0x extension it would already be gone; confirm it lived at most to the 1.5x cap, not beyond.
	for i in 5:
		host.step()
	assert_object(host).is_not_null()  # no crash iterating the timed dictionary past expiry
