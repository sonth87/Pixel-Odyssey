extends Node2D
## Development scene: shows a character strip folder at the runner's player position.

const GROUND_Y := 148
const PLAYER_X := 64

@export_dir var strip_folder := "res://content/onepiece/characters/luffy/sprites/base"
@export var frame_size := Vector2i(64, 64)
@export var animation := &"idle"

@onready var _sprite: AnimatedSprite2D = %Sprite


func _ready() -> void:
	_sprite.sprite_frames = SpriteStripLoader.build(strip_folder, frame_size)
	_sprite.centered = true
	_sprite.offset = Vector2(0, -frame_size.y / 2.0)
	_sprite.position = Vector2(PLAYER_X, GROUND_Y)
	_sprite.play(animation)
