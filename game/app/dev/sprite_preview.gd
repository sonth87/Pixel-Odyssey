extends Node2D
## Development scene: shows a character strip folder at the runner's player position.
## Click, tap, Space or Right/Left arrows switch between the animations found in the folder.

const GROUND_Y := 148
const PLAYER_X := 64

@export_dir var strip_folder := "res://content/onepiece/characters/luffy/sprites/base"
@export var frame_size := Vector2i(64, 64)
@export var animation := &"idle"

var _names: Array[StringName] = []
var _index := 0

@onready var _sprite: AnimatedSprite2D = %Sprite
@onready var _label: Label = %Name


func _ready() -> void:
	_sprite.sprite_frames = SpriteStripLoader.build(strip_folder, frame_size)
	_sprite.offset = Vector2(0, -frame_size.y / 2.0)
	_sprite.position = Vector2(PLAYER_X, GROUND_Y)
	for tag in _sprite.sprite_frames.get_animation_names():
		_names.append(StringName(tag))
	_names.sort()
	_index = maxi(_names.find(animation), 0)
	_play()


func _unhandled_input(event: InputEvent) -> void:
	var pointer_down := false
	if event is InputEventMouseButton:
		pointer_down = (event as InputEventMouseButton).pressed
	elif event is InputEventScreenTouch:
		pointer_down = (event as InputEventScreenTouch).pressed
	if pointer_down or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_right"):
		_step(1)
	elif event.is_action_pressed("ui_left"):
		_step(-1)


func _step(direction: int) -> void:
	_index = posmod(_index + direction, _names.size())
	_play()


func _play() -> void:
	var tag := _names[_index]
	_sprite.play(tag)
	var frames := _sprite.sprite_frames
	_label.text = "%s  (%d/%d)  %d frames  %.0f fps  %s" % [
		tag, _index + 1, _names.size(), frames.get_frame_count(tag),
		frames.get_animation_speed(tag), "loop" if frames.get_animation_loop(tag) else "once"]
