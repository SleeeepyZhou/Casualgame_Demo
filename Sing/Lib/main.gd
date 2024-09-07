extends CenterContainer

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Lib/game/game.tscn")

func _on_tool_pressed():
	get_tree().change_scene_to_file("res://Lib/tool/tool.tscn")

func _on_esc_button_up():
	get_tree().quit()

func _on_start_mouse_entered():
	$Box/Buttonbox/Start/Bird.visible = true

func _on_start_mouse_exited():
	$Box/Buttonbox/Start/Bird.visible = false

func _on_tool_mouse_entered():
	$Box/Buttonbox/Tool/Watermelon.visible = true

func _on_tool_mouse_exited():
	$Box/Buttonbox/Tool/Watermelon.visible = false
