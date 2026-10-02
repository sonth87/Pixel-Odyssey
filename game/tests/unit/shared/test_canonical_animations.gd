extends GdUnitTestSuite


func test_idle_loops_at_6_fps() -> void:
	assert_float(CanonicalAnimations.fps(&"idle")).is_equal(6.0)
	assert_bool(CanonicalAnimations.loops(&"idle")).is_true()


func test_form_tag_uses_base_tag_playback() -> void:
	assert_float(CanonicalAnimations.fps(&"form_run")).is_equal(CanonicalAnimations.fps(&"run"))
	assert_bool(CanonicalAnimations.loops(&"form_run")).is_true()


func test_skill_phases_play_once_with_phase_fps() -> void:
	assert_float(CanonicalAnimations.fps(&"skill_3_startup")).is_equal(12.0)
	assert_float(CanonicalAnimations.fps(&"skill_3_active")).is_equal(15.0)
	assert_bool(CanonicalAnimations.loops(&"skill_3_recovery")).is_false()


func test_unknown_tag_falls_back_to_default() -> void:
	assert_float(CanonicalAnimations.fps(&"something_new")).is_equal(CanonicalAnimations.DEFAULT_FPS)
	assert_bool(CanonicalAnimations.loops(&"something_new")).is_false()


func test_run_fast_loops_faster_than_run() -> void:
	assert_float(CanonicalAnimations.fps(&"run_fast")).is_greater(CanonicalAnimations.fps(&"run"))
	assert_bool(CanonicalAnimations.loops(&"run_fast")).is_true()
