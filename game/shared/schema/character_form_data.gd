class_name CharacterFormData
extends Resource
## One visual form of a character — the normal body, or a transform like Gear 4
## (docs/05-technical/04-data-schemas.md § CharacterFormData).

enum SizeClass { STANDARD_64, WIDE_128x64, LARGE_96, HUGE_128 }

@export var id: StringName
@export var name_key: String
@export var animation_set: AnimationSet
@export var size_class: SizeClass = SizeClass.STANDARD_64


func missing_required_tags() -> Array[StringName]:
	var required := CanonicalAnimations.RUNNER_REQUIRED if id == &"base" else CanonicalAnimations.RUNNER_FORM_REQUIRED
	return animation_set.missing_tags(required)
