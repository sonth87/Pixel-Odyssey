extends GdUnitTestSuite
## Regression test for a real playtest complaint: two different "empty" chunks (or two chunks whose
## content both sit far from their own edges) could chain into several seconds with nothing to react to,
## even though no single chunk was literally empty and the validator had nothing to flag (it only proves
## a chunk is clearable, not that the sequence feels alive). This checks the actual stitched sequence a
## player would run through, across many seeds, the way a human notices pacing — not just one chunk.

const ISLAND := "res://content/common/greybox/greybox_island.tres"
const START_RUNWAY_PX := 320
const PLAYER_START_PX := 32
const SEEDS_TO_CHECK := 150
const MAX_GAP_PX := 450  ## ~2.8s at the slowest island speed (140 px/s) — the documented calm-open beat
## (06-difficulty-and-pacing.md §2) is ~3s, once, at the very start; no stretch anywhere should exceed it.


func test_no_seed_has_a_dead_stretch_longer_than_the_documented_opening_beat() -> void:
	var island: IslandData = load(ISLAND)
	var segment := island.segments[0]
	for seed_value in range(1, SEEDS_TO_CHECK):
		var worst := _worst_gap(segment, seed_value)
		assert_int(worst).append_failure_message(
			"seed %d has a %d px stretch with nothing to react to" % [seed_value, worst]
		).is_less_equal(MAX_GAP_PX)


## Largest distance, anywhere in 6000+ px of generated content, between the end of one hazard (obstacle
## or pit) and the start of the next — the measure a player actually feels.
func _worst_gap(segment: SegmentData, seed_value: int) -> int:
	var spawner := ChunkSpawner.new(RngStreams.new(seed_value).stream(&"chunks"))
	spawner.next_x_px = START_RUNWAY_PX
	var terrain := Terrain.new()
	terrain.append_span(0, ChunkLayout.GROUND_Y_PX)
	var obstacles: Array[ObstacleState] = []
	while spawner.next_x_px < START_RUNWAY_PX + 6000:
		spawner.place(spawner.choose(segment.chunk_pool, 160, 2), segment.obstacle_set, terrain, obstacles)
	var events := PackedInt32Array()
	for o: ObstacleState in obstacles:
		events.append(Fixed.to_px(o.hitbox().position.x))
	for i in terrain.span_count():
		if terrain.span_y(i) == Terrain.NO_GROUND:
			events.append(terrain.span_start(i))
	events.sort()
	var worst := events[0] - PLAYER_START_PX
	for i in range(1, events.size()):
		worst = maxi(worst, events[i] - events[i - 1])
	return worst
