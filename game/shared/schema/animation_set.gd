class_name AnimationSet
extends Resource
## One form's animations: a folder of per-tag PNG strips (D-029) plus the frame geometry needed to
## slice and pivot them (docs/05-technical/04-data-schemas.md § AnimationSet).

@export_dir var strip_folder: String
@export var frame_size := Vector2i(64, 64)
## Point in the frame that sits at the node origin; bottom-center by default.
@export var pivot := Vector2i(32, 64)

var _frames: SpriteFrames


func sprite_frames() -> SpriteFrames:
	if _frames == null:
		_frames = SpriteStripLoader.build(strip_folder, frame_size)
	return _frames


func has_tag(tag: StringName) -> bool:
	return sprite_frames().has_animation(tag)


func missing_tags(required: Array[StringName]) -> Array[StringName]:
	return required.filter(func(tag: StringName) -> bool: return not has_tag(tag))
