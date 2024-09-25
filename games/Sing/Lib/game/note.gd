extends RigidBody2D

var note : String = "":
	set(text):
		note = text
		$Label.text = text
		linear_velocity = Vector2(randf_range(-1,1),1) * 50

func _on_visible_enabler_screen_exited():
	queue_free()
