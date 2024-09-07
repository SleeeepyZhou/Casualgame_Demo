extends CenterContainer

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Lib/game/game.tscn")

func _on_tool_pressed():
	get_tree().change_scene_to_file("res://Lib/tool/tool.tscn")

func _on_esc_button_up():
	get_tree().quit()
