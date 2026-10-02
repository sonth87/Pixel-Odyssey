class_name Terrain
extends RefCounted
## Ground profile of the run as consecutive horizontal spans in world pixels.
## Each span holds the ground line y from its start until the next span; NO_GROUND marks a pit.

const NO_GROUND := 1 << 30

var _starts := PackedInt32Array()
var _ys := PackedInt32Array()


## Spans must be appended left to right; an equal-height neighbour is merged.
func append_span(start_px: int, ground_y_px: int) -> void:
	assert(_starts.is_empty() or start_px > _starts[-1], "terrain spans must be appended in order")
	if not _ys.is_empty() and _ys[-1] == ground_y_px:
		return
	_starts.append(start_px)
	_ys.append(ground_y_px)


func ground_at(x_px: int) -> int:
	var index := _starts.bsearch(x_px, false) - 1
	return NO_GROUND if index < 0 else _ys[index]


## Highest ground (smallest y) over the inclusive pixel range.
func highest_in(from_px: int, to_px: int) -> int:
	var index := maxi(_starts.bsearch(from_px, false) - 1, 0)
	var best := NO_GROUND
	while index < _starts.size() and _starts[index] <= to_px:
		var span_end := _starts[index + 1] - 1 if index + 1 < _starts.size() else to_px
		if span_end >= from_px:
			best = mini(best, _ys[index])
		index += 1
	return best


func drop_before(x_px: int) -> void:
	var keep_from := _starts.bsearch(x_px, false) - 1
	if keep_from > 0:
		_starts = _starts.slice(keep_from)
		_ys = _ys.slice(keep_from)


func span_count() -> int:
	return _starts.size()


func span_start(index: int) -> int:
	return _starts[index]


func span_y(index: int) -> int:
	return _ys[index]
