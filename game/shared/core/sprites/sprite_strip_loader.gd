class_name SpriteStripLoader
## Builds SpriteFrames from a folder of animation strips: one horizontal PNG per tag (D-029).


static func build(folder: String, frame_size: Vector2i) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for file in ResourceLoader.list_directory(folder):
		if file.get_extension() != "png":
			continue
		var texture: Texture2D = load(folder.path_join(file))
		_add_strip(frames, StringName(file.get_basename()), texture, frame_size)
	return frames


static func _add_strip(frames: SpriteFrames, tag: StringName, texture: Texture2D, frame_size: Vector2i) -> void:
	var count := texture.get_width() / frame_size.x
	assert(count * frame_size.x == texture.get_width(), "strip %s is not a multiple of the frame width" % tag)
	assert(texture.get_height() == frame_size.y, "strip %s height differs from the frame height" % tag)
	frames.add_animation(tag)
	frames.set_animation_speed(tag, CanonicalAnimations.fps(tag))
	frames.set_animation_loop(tag, CanonicalAnimations.loops(tag))
	for index in count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(index * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(tag, atlas)
