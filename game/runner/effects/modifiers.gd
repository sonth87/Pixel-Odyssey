class_name Modifiers
extends RefCounted
## Combined, clamped result of every currently-active effect (docs/01-game-design/04-items-and-powerups.md
## §6 for the clamps). CollisionResolver and RunnerBody only ever read this — never "what item is active" —
## so a new item never requires touching either of them.

const MAX_SPEED_MULT := 1.5
const MAX_JUMP_MULT := 1.4
const MAX_SIZE_MULT := 2.0

var speed_mult := 1.0
var jump_mult := 1.0
var size_mult := 1.0
var rush := false
var destroy_filter: Array[StringName] = []
var phase_filter: Array[StringName] = []


static func combine(effects: Array[EffectData]) -> Modifiers:
	var result := Modifiers.new()
	for effect in effects:
		if effect is SpeedMultEffect:
			result.speed_mult *= (effect as SpeedMultEffect).factor
		elif effect is JumpMultEffect:
			result.jump_mult *= (effect as JumpMultEffect).factor
		elif effect is SizeMultEffect:
			result.size_mult *= (effect as SizeMultEffect).factor
		elif effect is RushEffect:
			result.rush = true
		elif effect is DestroyOnContactEffect:
			result.destroy_filter.append_array((effect as DestroyOnContactEffect).filter)
		elif effect is PhaseThroughEffect:
			result.phase_filter.append_array((effect as PhaseThroughEffect).filter)
	result.speed_mult = minf(result.speed_mult, MAX_SPEED_MULT)
	result.jump_mult = minf(result.jump_mult, MAX_JUMP_MULT)
	result.size_mult = minf(result.size_mult, MAX_SIZE_MULT)
	return result


func destroys(category: StringName) -> bool:
	return ObstacleFilter.matches(destroy_filter, category)


func phases_through(category: StringName) -> bool:
	return ObstacleFilter.matches(phase_filter, category)
