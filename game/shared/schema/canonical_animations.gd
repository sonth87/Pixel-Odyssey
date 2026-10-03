class_name CanonicalAnimations
## Default playback (fps, loop) and required-tag groups for the standard animation tags of
## docs/02-art/02-character-animation-spec.md §2.

## Base form, every runner character (§2.1–2.3). `eat`/`transform_enter`/`transform_exit` are only
## required for a character whose data actually has a transform (checked separately, not listed here).
const RUNNER_REQUIRED: Array[StringName] = [
	&"idle", &"run", &"run_fast", &"jump_start", &"jump_rise", &"jump_apex", &"fall", &"land",
	&"hurt", &"death_hit", &"death_lie",
]
## A transform form's own animation set (§2.4).
const RUNNER_FORM_REQUIRED: Array[StringName] = [
	&"form_idle", &"form_run", &"form_jump_rise", &"form_fall", &"form_land", &"form_attack",
]
## Game 2 (action) — not checked by game 1, listed so the tag names are fixed now.
const ACTION_REQUIRED: Array[StringName] = [
	&"walk", &"attack_1_startup", &"attack_1_active", &"attack_1_recovery",
]

const DEFAULT_FPS := 10.0

const _PLAYBACK := {
	&"idle": [6.0, true],
	&"run": [12.0, true],
	&"run_fast": [15.0, true],
	&"jump_start": [15.0, false],
	&"jump_rise": [10.0, true],
	&"jump_apex": [10.0, false],
	&"fall": [10.0, true],
	&"land": [15.0, false],
	&"double_jump": [15.0, false],
	&"walk": [10.0, true],
	&"dash": [15.0, false],
	&"crouch": [10.0, false],
	&"sit": [10.0, false],
	&"sit_idle": [6.0, true],
	&"lie_prone": [10.0, false],
	&"lie_supine": [10.0, false],
	&"get_up": [10.0, false],
	&"cheer": [8.0, true],
	&"taunt": [8.0, true],
	&"hurt": [12.0, false],
	&"death_hit": [12.0, false],
	&"death_lie": [10.0, false],
	&"death_fall": [10.0, true],
	&"knockback": [12.0, false],
	&"knockdown": [10.0, false],
	&"block": [10.0, false],
	&"pickup": [12.0, false],
	&"eat": [12.0, false],
	&"transform_enter": [15.0, false],
	&"transform_exit": [15.0, false],
}

const _PHASE_FPS := {&"startup": 12.0, &"active": 15.0, &"recovery": 12.0}


static func fps(tag: StringName) -> float:
	return _lookup(tag)[0]


static func loops(tag: StringName) -> bool:
	return _lookup(tag)[1]


static func _lookup(tag: StringName) -> Array:
	var name := String(tag)
	if name.begins_with("form_"):
		name = name.trim_prefix("form_")
		if name == "attack":
			return [15.0, false]
	if _PLAYBACK.has(StringName(name)):
		return _PLAYBACK[StringName(name)]
	var phase := StringName(name.get_slice("_", name.get_slice_count("_") - 1))
	if (name.begins_with("skill_") or name.contains("attack_")) and _PHASE_FPS.has(phase):
		return [_PHASE_FPS[phase], false]
	return [DEFAULT_FPS, false]
