extends Control

func _ready():
	$CenterContainer/TextureRect.visible = true
	$CenterContainer/TextureRect/Audio.play()
	await $CenterContainer/TextureRect/Audio.finished
	$CenterContainer/TextureRect.visible = false

func _on_tetris_button_up():
	get_tree().change_scene_to_file("res://games/Tetris/tetris.tscn")

func _on_tictactoe_button_up():
	get_tree().change_scene_to_file("res://games/Tictactoe/tictactoe.tscn")

func _on_gobang_button_up():
	get_tree().change_scene_to_file("res://games/Gobang/gobang.tscn")

func _on_sing_pressed():
	get_tree().change_scene_to_file("res://games/Sing/main.tscn")

func _on_moto_button_up():
	pass # Replace with function body.

func _on_esc_button_up():
	get_tree().change_scene_to_file("res://main/mainmenu.tscn")
	pass # Replace with function body.

