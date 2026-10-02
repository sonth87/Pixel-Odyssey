extends Node2D
## Development scene: shows character strip folders at the runner's player position.
## Click, tap, Space or Right/Left arrows switch animations; Up/Down arrows switch characters.

const GROUND_Y := 148
const PLAYER_X := 64

@export_dir var strip_folders: PackedStringArray = [
	"res://content/onepiece/characters/luffy/sprites/base",
	"res://content/samples/runa/sprites/base",
]
@export var frame_sizes: Array[Vector2i] = [Vector2i(64, 64), Vector2i(96, 96)]
@export var animation := &"idle"

var _names: Array[StringName] = []
var _index := 0
var _character := 0

@onready var _sprite: AnimatedSprite2D = %Sprite
@onready var _label: Label = %Name


func _ready() -> void:
	assert(strip_folders.size() == frame_sizes.size(), "one frame size per strip folder")
	_load_character()


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
	elif event.is_action_pressed("ui_down"):
		_switch_character(1)
	elif event.is_action_pressed("ui_up"):
		_switch_character(-1)


func _switch_character(direction: int) -> void:
	_character = posmod(_character + direction, strip_folders.size())
	_load_character()


func _load_character() -> void:
	var frame_size := frame_sizes[_character]
	_sprite.sprite_frames = SpriteStripLoader.build(strip_folders[_character], frame_size)
	_sprite.offset = Vector2(0, -frame_size.y / 2.0)
	_sprite.position = Vector2(PLAYER_X, GROUND_Y)
	_names.clear()
	for tag in _sprite.sprite_frames.get_animation_names():
		_names.append(StringName(tag))
	_names.sort()
	_index = maxi(_names.find(animation), 0)
	_play()


func _step(direction: int) -> void:
	_index = posmod(_index + direction, _names.size())
	_play()


func _play() -> void:
	var tag := _names[_index]
	_sprite.play(tag)
	var frames := _sprite.sprite_frames
	_label.text = "%s · %s  (%d/%d)  %d frames  %.0f fps  %s" % [
		strip_folders[_character].get_base_dir().get_base_dir().get_file(), tag, _index + 1, _names.size(),
		frames.get_frame_count(tag), frames.get_animation_speed(tag),
		"loop" if frames.get_animation_loop(tag) else "once"]
