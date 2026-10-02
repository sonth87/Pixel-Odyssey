class_name Fixed
## Integer fixed-point helpers for the deterministic simulation: 1 px = 256 subpixels, 60 ticks per second.

const SUB := 256
const TICKS_PER_SECOND := 60


## Division rounded toward negative infinity; GDScript's int `/` truncates toward zero.
static func fdiv(a: int, b: int) -> int:
	assert(b != 0, "division by zero")
	@warning_ignore("integer_division")
	var quotient := a / b
	if a % b != 0 and (a < 0) != (b < 0):
		quotient -= 1
	return quotient


static func velocity(px_per_second: float) -> int:
	return roundi(px_per_second * SUB / TICKS_PER_SECOND)


static func acceleration(px_per_second_squared: float) -> int:
	return roundi(px_per_second_squared * SUB / (TICKS_PER_SECOND * TICKS_PER_SECOND))


static func ticks(seconds: float) -> int:
	return roundi(seconds * TICKS_PER_SECOND)


static func from_px(px: int) -> int:
	return px * SUB


static func to_px(subpx: int) -> int:
	return fdiv(subpx, SUB)
