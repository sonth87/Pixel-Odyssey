class_name CharacterData
extends Resource
## A playable character, shared between game 1 and game 2 (docs/05-technical/04-data-schemas.md
## § CharacterData). Game 1's own view of this character (passive, transform, role skills) is a
## separate RunnerCharacterProfile that points here — this file never mentions runner concepts.

@export var id: StringName
@export var name_key: String
## First entry must be the `base` form.
@export var forms: Array[CharacterFormData] = []
@export var skills: Array[SkillData] = []
@export var palette_path: String
@export var sfx: Dictionary[StringName, AudioStream] = {}
@export var portrait: Texture2D


func base_form() -> CharacterFormData:
	return form(&"base")


func form(form_id: StringName) -> CharacterFormData:
	for f in forms:
		if f.id == form_id:
			return f
	return null


## Every form's required tags, prefixed with the form id for a readable report.
func missing_required_tags() -> Array[String]:
	var missing: Array[String] = []
	for f in forms:
		for tag in f.missing_required_tags():
			missing.append("%s.%s" % [f.id, tag])
	return missing
