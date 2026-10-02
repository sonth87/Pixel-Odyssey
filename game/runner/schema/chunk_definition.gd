class_name ChunkDefinition
extends Resource
## A hand-designed stretch of track (docs/01-game-design/02-run-journey-and-stages.md §5), authored as a
## text layout of 8 px columns (D-031). The bottom row is the standard ground line (y = 148).
##   '#' ground   '.' empty   l ground_low   t ground_tall   w ground_wide   e enemy_static   c enemy_moving
## A column without '#' is a pit. Obstacle letters stand on the ground of their column.

@export var id: StringName
@export_range(1, 5) var difficulty := 1
@export var weight := 10
@export var speed_min := 140.0
@export var speed_max := 300.0
@export var tags: Array[StringName] = []
@export var layout := PackedStringArray()
