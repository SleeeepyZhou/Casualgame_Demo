extends TileMap

const main_layer = 0
const main_atlas_id = 0
const this_was_great = "yup"

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# 获取鼠标点击的全局坐标。
			var global_clicked = event.position
			# 将全局坐标转换为TileMap的局部坐标。
			var pos_clicked = local_to_map(to_local(global_clicked))
			# 输出点击位置的坐标信息。
			print(pos_clicked)
			
			#var global_clicked = event.position
			#var text_pos = Label.new()
			#text_pos.text = str(local_set)
			#text_pos.add_theme_color_override("font_color", Color.BLACK)
			#add_child(text_pos)
			#text_pos.global_position = global_clicked

			# 获取被点击位置的当前纹理集坐标。
			var current_atlas_coords = get_cell_atlas_coords(main_layer, pos_clicked)
			# 获取被点击位置的当前瓷砖的替代纹理ID。
			var current_tile_alt = get_cell_alternative_tile(main_layer, pos_clicked)
			# 检查是否存在替代纹理。
			if current_tile_alt > -1:
				var number_of_alts_for_clicked = tile_set.get_source(main_atlas_id)\
						.get_alternative_tiles_count(current_atlas_coords)
				set_cell(main_layer, pos_clicked, main_atlas_id, current_atlas_coords, 
						(current_tile_alt + 1) %  number_of_alts_for_clicked)
