extends GdUnitTestSuite


func test_fdiv_rounds_toward_negative_infinity() -> void:
	assert_int(Fixed.fdiv(7, 2)).is_equal(3)
	assert_int(Fixed.fdiv(-7, 2)).is_equal(-4)
	assert_int(Fixed.fdiv(7, -2)).is_equal(-4)
	assert_int(Fixed.fdiv(-8, 2)).is_equal(-4)
	assert_int(Fixed.fdiv(-1, 256)).is_equal(-1)


func test_to_px_floors_negative_subpixels() -> void:
	assert_int(Fixed.to_px(-1)).is_equal(-1)
	assert_int(Fixed.to_px(255)).is_equal(0)
	assert_int(Fixed.to_px(256)).is_equal(1)


func test_conversions_match_the_determinism_doc_table() -> void:
	assert_int(Fixed.acceleration(1000.0)).is_equal(71)
	assert_int(Fixed.acceleration(600.0)).is_equal(43)
	assert_int(Fixed.acceleration(1150.0)).is_equal(82)
	assert_int(Fixed.velocity(260.0)).is_equal(1109)
	assert_int(Fixed.velocity(420.0)).is_equal(1792)
	assert_int(Fixed.velocity(220.0)).is_equal(939)
	assert_int(Fixed.velocity(300.0)).is_equal(1280)
	assert_int(Fixed.ticks(0.22)).is_equal(13)
