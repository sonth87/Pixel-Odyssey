extends GdUnitTestSuite


func _draw(streams: RngStreams, stream_name: StringName, count: int) -> Array[int]:
	var values: Array[int] = []
	for i in count:
		values.append(streams.stream(stream_name).randi_range(0, 1_000_000))
	return values


func test_same_seed_gives_same_sequence() -> void:
	assert_array(_draw(RngStreams.new(42), &"chunks", 20)).is_equal(_draw(RngStreams.new(42), &"chunks", 20))


func test_different_seeds_differ() -> void:
	assert_array(_draw(RngStreams.new(42), &"chunks", 20)).is_not_equal(_draw(RngStreams.new(43), &"chunks", 20))


func test_streams_are_independent() -> void:
	var clean := RngStreams.new(7)
	var noisy := RngStreams.new(7)
	_draw(noisy, &"cosmetic", 500)
	assert_array(_draw(noisy, &"chunks", 20)).is_equal(_draw(clean, &"chunks", 20))
	assert_array(_draw(clean, &"items", 20)).is_not_equal(_draw(clean, &"chunks", 20))
