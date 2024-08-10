extends Node2D

func _ready():
	pass

func _physics_process(delta):
	if end_test != []:
		for i in end_test:
			if i != null:
				if i.position.y > 32:
					end_test.erase(i)
		if end_test == []:
			test_time.stop()

# 游戏结束检测
@onready var test_time = $Timer
var end_test := []
signal game_over
func _on_body_entered(body):
	if test_time.is_stopped():
		test_time.start()
	end_test.append(body)
func _on_timer_timeout():
	if end_test != []:
		game_over.emit()
		test_time.stop()
