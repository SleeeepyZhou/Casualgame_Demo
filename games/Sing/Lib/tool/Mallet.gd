extends CharacterBody2D

var mouse_p : Vector2
@export var _v : int = 25

func _physics_process(delta):
	mouse_p = get_global_mouse_position()
	velocity = (mouse_p - global_position)*_v
	move_and_slide()
