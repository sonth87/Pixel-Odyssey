class_name EffectHost
extends RefCounted
## Everything currently affecting the player: permanent passives, the active transform (if any), a
## generic timed-effect slot for future items (devil fruits, speed items — not used before M6), and
## shield charges / i-frames. One Modifiers snapshot per tick is all other systems ever read
## (docs/05-technical/01-architecture.md §4.2).

enum TransformPhase { NONE, ENTERING, ACTIVE, EXITING, POST_IFRAMES }

const ENTER_TICKS := 24  ## 0.4 s (docs/01-game-design/03-characters-and-skills.md §4)
const EXIT_TICKS := 18   ## 0.3 s
const POST_IFRAMES_TICKS := 30  ## 0.5 s
const SHIELD_BREAK_IFRAMES_TICKS := 36  ## 0.6 s (interaction rules §2)
const MAX_SHIELD_CHARGES := 3
const MAX_TIMED_EXTENSION := 1.5  ## items §6.1: re-applying the same timed effect caps at 1.5x its base

var _passive: Array[EffectData] = []
var _shield_charges := 0
var _iframe_ticks := 0

var _transform_phase := TransformPhase.NONE
var _transform_phase_ticks := 0
var _transform_form_id: StringName
var _transform_effects: Array[EffectData] = []
var _transform_active_ticks := 0

## Generic timed slots keyed by an arbitrary id (a devil fruit id, "speed_item", ...), for anything other
## than the transform. Each entry: {effects, ticks, base_ticks}.
var _timed: Dictionary[StringName, Dictionary] = {}


func _init(passive: Array[EffectData] = []) -> void:
	_passive = passive


func modifiers() -> Modifiers:
	var active := _passive.duplicate()
	if _transform_phase == TransformPhase.ACTIVE:
		active.append_array(_transform_effects)
	for key: StringName in _timed:
		active.append_array((_timed[key].effects as Array[EffectData]))
	return Modifiers.combine(active)


func is_invulnerable() -> bool:
	return _iframe_ticks > 0 or _transform_phase in [TransformPhase.ENTERING, TransformPhase.EXITING, TransformPhase.POST_IFRAMES]


func has_shield() -> bool:
	return _shield_charges > 0


## Spends one charge and starts the post-break i-frames; call only when a shield is actually present.
func break_shield() -> void:
	assert(_shield_charges > 0, "no shield to break")
	_shield_charges -= 1
	_iframe_ticks = maxi(_iframe_ticks, SHIELD_BREAK_IFRAMES_TICKS)


func add_shield(charges: int) -> void:
	_shield_charges = mini(_shield_charges + charges, MAX_SHIELD_CHARGES)


func is_transforming() -> bool:
	return _transform_phase != TransformPhase.NONE


func transform_form_id() -> StringName:
	return _transform_form_id if _transform_phase != TransformPhase.NONE else &"base"


## First time: plays the enter animation (i-frames throughout). Rule §6.2 — eating again while already
## transformed just refreshes the active timer instead, no replayed enter and no stacking two forms.
func enter_transform(form_id: StringName, effects: Array[EffectData], base_duration_seconds: float) -> void:
	_transform_form_id = form_id
	_transform_effects = effects
	var active_ticks := effective_duration_ticks(base_duration_seconds)
	if _transform_phase == TransformPhase.NONE:
		_transform_phase = TransformPhase.ENTERING
		_transform_phase_ticks = ENTER_TICKS
		_transform_active_ticks = active_ticks
	else:
		_transform_phase = TransformPhase.ACTIVE
		_transform_phase_ticks = active_ticks


## Rule §6.1: re-applying the same timed slot extends it, capped at 1.5x the slot's own base duration.
func apply_timed(key: StringName, effects: Array[EffectData], duration_seconds: float) -> void:
	var ticks := effective_duration_ticks(duration_seconds)
	if _timed.has(key):
		var slot: Dictionary = _timed[key]
		slot.base_ticks = maxi(slot.base_ticks, ticks)
		slot.ticks = mini(slot.ticks + ticks, roundi(slot.base_ticks * MAX_TIMED_EXTENSION))
		slot.effects = effects
	else:
		_timed[key] = {"effects": effects, "ticks": ticks, "base_ticks": ticks}


## Scales a design duration by every active DurationMultEffect (Luffy's passive) — the one place that
## reads it, so an item's declared duration and what the player actually experiences can never drift.
func effective_duration_ticks(base_seconds: float) -> int:
	var factor := 1.0
	for effect in _passive:
		if effect is DurationMultEffect:
			factor *= (effect as DurationMultEffect).factor
	return Fixed.ticks(base_seconds * factor)


func step() -> void:
	if _iframe_ticks > 0:
		_iframe_ticks -= 1
	_step_transform()
	for key: StringName in _timed.keys().duplicate():
		var slot: Dictionary = _timed[key]
		slot.ticks -= 1
		if slot.ticks <= 0:
			_timed.erase(key)


func _step_transform() -> void:
	if _transform_phase == TransformPhase.NONE:
		return
	_transform_phase_ticks -= 1
	if _transform_phase_ticks > 0:
		return
	match _transform_phase:
		TransformPhase.ENTERING:
			_transform_phase = TransformPhase.ACTIVE
			_transform_phase_ticks = _transform_active_ticks
		TransformPhase.ACTIVE:
			_transform_phase = TransformPhase.EXITING
			_transform_phase_ticks = EXIT_TICKS
		TransformPhase.EXITING:
			_transform_phase = TransformPhase.POST_IFRAMES
			_transform_phase_ticks = POST_IFRAMES_TICKS
		TransformPhase.POST_IFRAMES:
			_transform_phase = TransformPhase.NONE
