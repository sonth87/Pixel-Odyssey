class_name ChunkGround
## Ground profile of a placed chunk: the layout's columns plus the tops of solid-top obstacles, which become
## terrain so landing, steps, corner correction and wall deaths apply to them unchanged (D-032).


## Returns chunk-local spans as Vector2i(start_px, ground_y_px), left to right.
static func spans(layout: ChunkLayout, slot_data: Array[ObstacleData]) -> Array[Vector2i]:
	var ground := PackedInt32Array()
	ground.resize(layout.width_px)
	for x in layout.width_px:
		ground[x] = layout.column_ground[Fixed.fdiv(x, ChunkLayout.COLUMN_PX)]
	for i in layout.slots.size():
		var data := slot_data[i]
		if not data.solid_top:
			continue
		var slot := layout.slots[i]
		var top := slot.y + data.hitbox.position.y
		for x in range(maxi(slot.x + data.hitbox.position.x, 0), mini(slot.x + data.hitbox.end.x, layout.width_px)):
			ground[x] = mini(ground[x], top)
	var result: Array[Vector2i] = []
	for x in layout.width_px:
		if result.is_empty() or result[-1].y != ground[x]:
			result.append(Vector2i(x, ground[x]))
	return result
