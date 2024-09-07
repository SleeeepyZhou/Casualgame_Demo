extends Control

func _on_start_button_down():
	get_tree().change_scene_to_file("res://main/list.tscn")

func _on_esc_button_up():
	get_tree().quit()

@onready var trick : VideoStreamPlayer = $CenterContainer/Rickroll
func _on_setting_pressed():
	trick.visible = true
	trick.play()

func _on_close_pressed():
	trick.visible = false
	trick.stop()
