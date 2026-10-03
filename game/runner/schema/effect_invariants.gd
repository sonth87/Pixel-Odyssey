class_name EffectInvariants
## Checks E1–E4 (docs/01-game-design/04-items-and-powerups.md §5): an effect may only ever make the
## player safer than the normal state chunks are validated against, never more exposed. Run this on every
## item, passive and transform form when a content pack loads (D-020); a violation is a loading error, not
## a gameplay bug to debug later.

static func check(effects: Array[EffectData], is_transform: bool = false) -> Array[String]:
	var errors: Array[String] = []
	var has_rush := _any(effects, RushEffect)
	var covers_all := _any(effects, DestroyOnContactEffect, func(e: DestroyOnContactEffect) -> bool: return e.filter.has(&"*"))
	var covers_air_hazards := _any(effects, DestroyOnContactEffect, func(e: DestroyOnContactEffect) -> bool:
		return ObstacleFilter.matches(e.filter, &"air") and ObstacleFilter.matches(e.filter, &"falling") \
			and ObstacleFilter.matches(e.filter, &"projectile"))

	for effect in effects:
		if effect is SpeedMultEffect:
			var factor: float = (effect as SpeedMultEffect).factor
			if factor > 1.0 and not has_rush:
				errors.append("E1: SpeedMultEffect(%.2f) > 1.0 without RushEffect" % factor)
			if factor < 1.0:
				errors.append("E4: SpeedMultEffect(%.2f) < 1.0 is never allowed" % factor)
		elif effect is JumpMultEffect:
			var factor: float = (effect as JumpMultEffect).factor
			if factor > 1.0 and not covers_air_hazards:
				errors.append("E3: JumpMultEffect(%.2f) > 1.0 without destroy_on_contact(air, falling, projectile)" % factor)
			if factor < 1.0:
				errors.append("E4: JumpMultEffect(%.2f) < 1.0 is never allowed" % factor)
		elif effect is SizeMultEffect:
			var factor: float = (effect as SizeMultEffect).factor
			if factor > 1.0 and not covers_all:
				errors.append("E2: SizeMultEffect(%.2f) > 1.0 without destroy_on_contact(*)" % factor)
			if factor < 1.0:
				errors.append("E4: SizeMultEffect(%.2f) < 1.0 is never allowed" % factor)

	if is_transform and not covers_all:
		errors.append("E2: transform form has no destroy_on_contact(*)")
	return errors


static func _any(effects: Array[EffectData], type: Script, predicate: Callable = Callable()) -> bool:
	for effect in effects:
		if is_instance_of(effect, type) and (not predicate.is_valid() or predicate.call(effect)):
			return true
	return false
