class_name SkillData
extends Resource
## One of a character's up to 5 skills (docs/05-technical/04-data-schemas.md § SkillData). Game 1 only
## uses a skill when RunnerCharacterProfile.role_skills assigns it a role (transform_attack, ...); the
## rest are data for game 2. Phase durations come from the skill_<slot>_* animation frame counts, not a
## hand-entered number, so data and art can never drift apart.

@export_range(1, 5) var slot := 1
@export var id: StringName
@export var name_key: String
@export var form_id: StringName = &"base"
@export var vfx: PackedScene
@export var sfx: AudioStream
## Abstract power, interpreted as damage/crit by game 2; unused by game 1.
@export var magnitude := 0.0
@export var tags: Array[StringName] = []
