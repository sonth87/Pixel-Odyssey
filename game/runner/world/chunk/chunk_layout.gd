class_name ChunkLayout
extends RefCounted
## Parsed form of a ChunkDefinition layout, in chunk-local pixels.

const COLUMN_PX := 8
const GROUND_Y_PX := 148
const GROUND := "#"
const EMPTY := "."
const CATEGORIES := {
	"l": &"ground_low",
	"t": &"ground_tall",
	"w": &"ground_wide",
	"e": &"enemy_static",
	"c": &"enemy_moving",
}

var width_px := 0
## Ground line per column in px, Terrain.NO_GROUND for pits.
var column_ground := PackedInt32Array()
## Each slot: Vector3i(x_px of the pivot, ground_y_px, column index); categories in `slot_categories`.
var slots: Array[Vector3i] = []
var slot_categories: Array[StringName] = []
var errors: Array[String] = []


static func parse(chunk: ChunkDefinition) -> ChunkLayout:
	var parsed := ChunkLayout.new()
	parsed._parse(chunk.layout)
	return parsed


func entry_y() -> int:
	return column_ground[0] if not column_ground.is_empty() else Terrain.NO_GROUND


func exit_y() -> int:
	return column_ground[-1] if not column_ground.is_empty() else Terrain.NO_GROUND


func _parse(rows: PackedStringArray) -> void:
	if rows.is_empty():
		errors.append("layout is empty")
		return
	var columns := rows[0].length()
	for row in rows:
		if row.length() != columns:
			errors.append("rows have different lengths")
			return
	width_px = columns * COLUMN_PX
	for column in columns:
		column_ground.append(_column_ground(rows, column))
	for column in columns:
		_read_slots(rows, column)


func _column_ground(rows: PackedStringArray, column: int) -> int:
	for row in rows.size():
		if rows[row][column] == GROUND:
			return GROUND_Y_PX - (rows.size() - 1 - row) * COLUMN_PX
	return Terrain.NO_GROUND


func _read_slots(rows: PackedStringArray, column: int) -> void:
	for row in rows:
		var symbol := row[column]
		if symbol == GROUND or symbol == EMPTY:
			continue
		if not CATEGORIES.has(symbol):
			errors.append("unknown symbol '%s' in column %d" % [symbol, column])
		elif column_ground[column] == Terrain.NO_GROUND:
			errors.append("obstacle over a pit in column %d" % column)
		else:
			slots.append(Vector3i(column * COLUMN_PX + (COLUMN_PX >> 1), column_ground[column], column))
			slot_categories.append(CATEGORIES[symbol])
