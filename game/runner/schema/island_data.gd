class_name IslandData
extends Resource
## An island of the journey: fixed length, speed ramp, difficulty ramp and segments
## (docs/01-game-design/02-run-journey-and-stages.md §3, physics doc §3).

@export var id: StringName
@export var length_m := 1500
@export var speed_start := 140.0
@export var speed_end := 260.0
@export_range(1, 5) var difficulty_min := 1
@export_range(1, 5) var difficulty_max := 4
@export var segments: Array[SegmentData] = []


## Segment at a progress through the island in per mille; past the end the last segment continues.
func segment_at(progress_permille: int) -> SegmentData:
	assert(not segments.is_empty(), "island %s has no segments" % id)
	var end_permille := 0
	for segment in segments:
		end_permille += segment.length_percent * 10
		if progress_permille < end_permille:
			return segment
	return segments[-1]
