class_name ObstacleFilter
## A set of obstacle categories an effect applies to (docs/05-technical/04-data-schemas.md). An entry
## ending in `*` matches any category with that prefix (`enemy_*` matches `enemy_static`).

const ALL: Array[StringName] = [&"*"]


static func matches(filter: Array[StringName], category: StringName) -> bool:
	var text := String(category)
	for entry in filter:
		var pattern := String(entry)
		if pattern == "*" or pattern == text:
			return true
		if pattern.ends_with("*") and text.begins_with(pattern.left(pattern.length() - 1)):
			return true
	return false
