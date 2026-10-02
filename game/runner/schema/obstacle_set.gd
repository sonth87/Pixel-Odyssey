class_name ObstacleSet
extends Resource
## The concrete obstacles a segment may use; chunks only name categories (docs/05-technical/04-data-schemas.md).

@export var obstacles: Array[ObstacleData] = []


func variants(category: StringName) -> Array[ObstacleData]:
	var matching: Array[ObstacleData] = []
	for obstacle in obstacles:
		if obstacle.category == category:
			matching.append(obstacle)
	return matching


func pick(category: StringName, rng: RandomNumberGenerator) -> ObstacleData:
	var choices := variants(category)
	assert(not choices.is_empty(), "obstacle set has nothing for category %s" % category)
	return choices[rng.randi_range(0, choices.size() - 1)]
