class_name RunSimulation
extends RefCounted
## One run of the runner as a pure, deterministic integer simulation: seed + input per tick gives the same
## result on every machine. Scenes only feed input and draw the state.

const START_RUNWAY_PX := 320
const PLAYER_START_PX := 32
const LOOKAHEAD_PX := 640
const KEEP_BEHIND_PX := 160
const DEATH_Y_PX := 196
const PX_PER_METER := 16

var tick := 0
var body: RunnerBody
var terrain := Terrain.new()
var obstacles: Array[ObstacleState] = []
var spawner: ChunkSpawner
var recording := InputRecording.new()
var stomps := 0
var effects: EffectHost

var _island: IslandData
var _speed_start: int
var _speed_end: int
var _length: int
var _start_x: int


func _init(physics: JumpPhysics, island: IslandData, rng: RngStreams, passive_effects: Array[EffectData] = []) -> void:
	_island = island
	effects = EffectHost.new(passive_effects)
	_speed_start = Fixed.velocity(island.speed_start)
	_speed_end = Fixed.velocity(island.speed_end)
	_length = Fixed.from_px(island.length_m * PX_PER_METER)
	_start_x = Fixed.from_px(PLAYER_START_PX)
	terrain.append_span(0, ChunkLayout.GROUND_Y_PX)
	spawner = ChunkSpawner.new(rng.stream(&"chunks"))
	spawner.next_x_px = START_RUNWAY_PX
	body = RunnerBody.new(physics, terrain)
	body.x = _start_x
	body.y = Fixed.from_px(ChunkLayout.GROUND_Y_PX)
	body.death_y = Fixed.from_px(DEATH_Y_PX)
	_fill_ahead()


func step(input: TickInput) -> void:
	if body.is_dead():
		return
	recording.record(tick, input)
	var feet := body.y
	body.step(input, speed_at(body.x))
	for obstacle in obstacles:
		obstacle.step(body.x)
	stomps += CollisionResolver.resolve(body, obstacles, feet, effects).size()
	effects.step()
	tick += 1
	_fill_ahead()
	_drop_passed()


## Base running speed in subpixels per tick at a world x in subpixels.
func speed_at(x: int) -> int:
	var travelled := clampi(x - _start_x, 0, _length)
	return _speed_start + Fixed.fdiv((_speed_end - _speed_start) * Fixed.to_px(travelled), Fixed.to_px(_length))


func speed_px_per_second(x: int) -> int:
	return Fixed.fdiv(speed_at(x) * Fixed.TICKS_PER_SECOND + (Fixed.SUB >> 1), Fixed.SUB)


func distance_m() -> int:
	return Fixed.fdiv(Fixed.to_px(body.x - _start_x), PX_PER_METER)


func progress_permille(x: int) -> int:
	return Fixed.fdiv(Fixed.to_px(clampi(x - _start_x, 0, _length)) * 1000, Fixed.to_px(_length))


func target_difficulty(x: int) -> int:
	var span := _island.difficulty_max - _island.difficulty_min
	return _island.difficulty_min + Fixed.fdiv(span * progress_permille(x) + 500, 1000)


func _fill_ahead() -> void:
	while spawner.next_x_px < Fixed.to_px(body.x) + LOOKAHEAD_PX:
		var at := Fixed.from_px(spawner.next_x_px)
		var segment := _island.segment_at(progress_permille(at))
		var chunk := spawner.choose(segment.chunk_pool, speed_px_per_second(at), target_difficulty(at))
		spawner.place(chunk, segment.obstacle_set, terrain, obstacles)


func _drop_passed() -> void:
	var behind := Fixed.from_px(Fixed.to_px(body.x) - KEEP_BEHIND_PX)
	while not obstacles.is_empty() and obstacles[0].x < behind:
		obstacles.pop_front()
	terrain.drop_before(Fixed.to_px(behind))
