extends Node2D

var player : Node2D
var score : int = 0:
	set(i):
		$Pausebutton/Score.text = str(i)
		score = i
var song_data : Array

func _ready():
	#var midi := []
	#for i in range(48, 84):
		#var h = Readcsv.PName[i%12] + str(i/12 - 1)
		#if "#" in h:
			#continue
		#midi.append(i)
	#print(midi)
	
	#position = get_viewport_rect().size / 2
	
	$PipeBox.position.x = get_viewport_rect().size.x / 2
	_on_song_pressed()

func _process(delta):
	$ParallaxBackground.scroll_base_offset.x -= 100 * delta

var win := false
func sing():
	var lastpipe
	for data in song_data:
		if $Menu/Game.visible:
			return
		if get_tree().paused:
			while get_tree().paused:
				await get_tree().create_timer(0.5).timeout
		var pipe_sec = load("res://games/Sing/Lib/game/obstacle.tscn")
		var pipe = pipe_sec.instantiate()
		$PipeBox.add_child(pipe)
		pipe.screat = data
		lastpipe = pipe
		await get_tree().create_timer(data.y).timeout
	await lastpipe.tree_exiting
	if score > 0:
		win = true
		game_over()

func _on_timer_timeout():
	score += 1

func game_over():
	var tip = $Menu/Game/Label
	$Menu/Game.visible = true
	if win:
		tip.text = "You win \n"
	else:
		tip.text = "You die \n"
	tip.text += "Score :" + str(score)
	_on_stop_button()

func _on_song_pressed():
	$Menu/Box/Song.clear()
	var songlist = Readcsv.read_csvlist()
	for i in songlist:
		$Menu/Box/Song.add_item(i)

func _on_start_pressed():
	song_data = Readcsv.parse_csv_file($Menu/Box/Song.text)
	player = load("res://games/Sing/Lib/game/player.tscn").instantiate()
	add_child(player)
	player.gameover.connect(game_over)
	move_child(player,0)
	$Menu.visible = false
	$Pausebutton.visible = true
	$Timer.start()
	win = false
	sing()

func _on_stop_button():
	get_tree().paused = false
	score = 0
	for child in $PipeBox.get_children():
		child.queue_free()
	player.queue_free()
	$Pause.visible = false
	$Pausebutton.visible = false
	$Menu.visible = true
	$Timer.stop()

func _on_back_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://games/Sing/main.tscn")

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		$Pause.visible = true
		get_tree().paused = true
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		$Pause.visible = false
		get_tree().paused = false

func _on_pausebutton_button_down():
	$Pause.visible = !$Pause.visible
	get_tree().paused = !get_tree().paused

func _on_restart_pressed():
	$Menu/Game.visible = false

func _on_help_pressed():
	$Menu/Box/Help/Tip.visible = !$Menu/Box/Help/Tip.visible
