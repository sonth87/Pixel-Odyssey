class_name ObstacleData
extends Resource
## One concrete obstacle or enemy (docs/05-technical/04-data-schemas.md). Chunks place categories;
## an ObstacleSet picks the concrete ObstacleData for each slot.

@export var id: StringName
## ground_low, ground_tall, ground_wide, enemy_static, enemy_moving, ...
@export var category: StringName
## Relative to the pivot: bottom-center, standing on the ground line.
@export var hitbox := Rect2i(-6, -12, 12, 12)
@export var behavior: ObstacleBehaviorData = StaticBehavior.new()
@export var destructible := true
@export var stompable := false
## Looks standable (crate, cart, step): its top is ground and only its sides kill (D-032). Static obstacles only.
@export var solid_top := false
@export var sprite_frames: SpriteFrames
