extends CharacterBody2D

const JUMP_VELOCITY = -200.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var hi : Array = ["", 69.0]

func _physics_process(delta):
	hi = $AudioTest.pitch
	var playery : float = clampf(hi[1],20,100)
	var yid : int = 19
	for i in range(1, Readcsv.gameplayer.size()):
		if playery > Readcsv.gameplayer[i] :
			continue
		yid = i - 1
	var hiratio : float = (playery - Readcsv.gameplayer[yid])/ \
				(Readcsv.gameplayer[yid+1]-Readcsv.gameplayer[yid])
	var tohi = float((Readcsv.gamey[yid+1]-Readcsv.gamey[yid]) * hiratio + Readcsv.gamey[yid])
	velocity.y = lerpf(position.y, tohi, 0.75) - position.y
	if position.x != 0:
		velocity.x = (-position.x / abs(position.x)) * 100
	else:
		velocity.x = 0
	
	if Input.is_action_just_pressed("ui_up") and OS.is_debug_build():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()

signal gameover
func _on_out_screen():
	emit_signal("gameover")
	queue_free()

func _on_timer_timeout():
	var note_res = load("res://Lib/game/note.tscn")
	if hi[1] > 40.0:
		var note = note_res.instantiate()
		note.position.y -= 30
		note.note = hi[0]
		$Box.add_child(note)
