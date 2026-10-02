extends GdUnitTestSuite

const LUFFY_BASE := "res://content/onepiece/characters/luffy/sprites/base"


func test_builds_one_animation_per_strip_with_sliced_frames() -> void:
	var frames := SpriteStripLoader.build(LUFFY_BASE, Vector2i(64, 64))

	assert_bool(frames.has_animation(&"idle")).is_true()
	assert_bool(frames.has_animation(&"default")).is_false()
	assert_int(frames.get_frame_count(&"idle")).is_equal(4)
	var second: AtlasTexture = frames.get_frame_texture(&"idle", 1)
	assert_that(second.region).is_equal(Rect2(64, 0, 64, 64))


func test_applies_canonical_playback() -> void:
	var frames := SpriteStripLoader.build(LUFFY_BASE, Vector2i(64, 64))

	assert_float(frames.get_animation_speed(&"idle")).is_equal(6.0)
	assert_bool(frames.get_animation_loop(&"idle")).is_true()
