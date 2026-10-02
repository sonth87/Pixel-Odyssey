extends SceneTree
## Validates every chunk of every island under res://content against its segment's obstacle set.
## godot --headless --path game -s res://runner/validation/validate_all.gd   (exit code 1 on any error)

const CONTENT_ROOT := "res://content"


func _initialize() -> void:
	var physics := RunnerPhysicsConfig.new().compile()
	var failures := 0
	var checked := 0
	for island in _find_islands(CONTENT_ROOT):
		for segment in island.segments:
			for chunk in segment.chunk_pool:
				checked += 1
				var errors := ChunkValidator.validate(chunk, segment.obstacle_set, physics)
				for error in errors:
					print("FAIL %s / %s: %s" % [island.id, segment.id, error])
				failures += 1 if not errors.is_empty() else 0
	print("%d chunk(s) checked, %d failed" % [checked, failures])
	quit(1 if failures > 0 else 0)


func _find_islands(folder: String) -> Array[IslandData]:
	var islands: Array[IslandData] = []
	for file in ResourceLoader.list_directory(folder):
		var path := folder.path_join(file)
		if file.ends_with("/"):
			islands.append_array(_find_islands(path.trim_suffix("/")))
		elif file.ends_with(".tres"):
			var resource := load(path)
			if resource is IslandData:
				islands.append(resource)
	return islands
