class_name SegmentData
extends Resource
## A fixed-scenery part of an island; its chunks are picked with controlled randomness
## (docs/01-game-design/02-run-journey-and-stages.md §4).

@export var id: StringName
@export_range(1, 100) var length_percent := 100
@export var chunk_pool: Array[ChunkDefinition] = []
@export var obstacle_set: ObstacleSet
