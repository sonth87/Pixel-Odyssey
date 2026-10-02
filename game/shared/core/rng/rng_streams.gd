class_name RngStreams
extends RefCounted
## Independent deterministic random streams derived from one run seed, so drawing from one stream never
## changes another (e.g. cosmetic decoration cannot alter the obstacle sequence).

const NAMES: Array[StringName] = [&"chunks", &"items", &"fruits", &"cosmetic"]

var seed_value: int

var _streams: Dictionary[StringName, RandomNumberGenerator] = {}


func _init(run_seed: int) -> void:
	seed_value = run_seed & 0xFFFFFFFF
	for stream_name in NAMES:
		var rng := RandomNumberGenerator.new()
		rng.seed = (seed_value << 32) | _fnv1a(String(stream_name))
		_streams[stream_name] = rng


func stream(stream_name: StringName) -> RandomNumberGenerator:
	assert(_streams.has(stream_name), "unknown RNG stream %s" % stream_name)
	return _streams[stream_name]


## 32-bit FNV-1a; kept below 2^56 at every step so no 64-bit overflow is involved.
static func _fnv1a(text: String) -> int:
	var hash_value := 2166136261
	for byte in text.to_utf8_buffer():
		hash_value = ((hash_value ^ byte) * 16777619) & 0xFFFFFFFF
	return hash_value
