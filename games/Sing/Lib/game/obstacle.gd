extends StaticBody2D

var speed = 200
var screat : Vector2 = Vector2.ZERO:
	set(h):
		screat = h
		position.y = Readcsv.gamey[h.x]
		$D/Pitch/Label.text = Readcsv.gamelist[h.x]
		#speed = speed / h.y
# y [底300, 顶-200] 500

func _physics_process(delta):
	position.x -= speed * delta

func _on_visible_screen_exited():
	queue_free()
