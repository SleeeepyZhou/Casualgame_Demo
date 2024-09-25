extends Node2D

# 方块相关
const BLOCK_TYPES = ["I", "O", "T", "J", "L", "S", "Z"]
const BLOCK_PATH = "res://games/Tetris/block/"
var list_block := []

@onready var next_texture = $"../../Data/TextureRect"
@onready var score_text = $"../../Data/Score"
@onready var game_timer = $"../Timer"
@onready var start_button = $"../../Data/Buttun/Start"
@onready var Pause_text = $"../../../Pause Label"
@onready var creat_pos = $"../Pos".global_position

@onready var tips = $"../../../../Control"
func _on_help_mouse_entered():
	tips.visible = true

func _on_help_mouse_exited():
	tips.visible = false

# 生成打乱
func block_rand() -> Array:
	var queue = BLOCK_TYPES.duplicate()
	randomize()
	queue.shuffle()
	return queue

# 生成方块
var current_block = null
var current := ""
var next := ""
var all_rigidbody := []
func block_creat():
	if list_block == []:
		list_block = block_rand()
	if current == "":
		current = BLOCK_PATH + list_block.pop_front()
		next = BLOCK_PATH + list_block.pop_front()
	else:
		current = next
		next = BLOCK_PATH + list_block.pop_front()
	next_texture.texture = load(next + ".png")
	var temp = load(current+".tscn")
	current_block = temp.instantiate()
	current_block.global_position = creat_pos
	add_child(current_block)
	for node in current_block.get_children():
		if node is RigidBody2D:
			all_rigidbody.append(node)

# 超时判定
var timeout := false
var drop_speed = 5
var settle_speed = 0.05
func _on_timer_timeout():
	if current_block.get_node("Bone-0") != null:
		var v = current_block.get_node("Bone-0").linear_velocity.length()
		if v > 10 and !timeout :
			timeout = true
			return
	timeout = false
	block_creat()

# 消除方块
var test_arr := []
var score := 0
func creat_test_box() -> Array:
	var test_box := []
	for i in range(19):
		test_box.append([])
	return test_box
func got_score():
	var test_interval = creat_test_box()
	# 遍历刚体
	for rb in all_rigidbody:
		if rb == null:
			all_rigidbody.erase(rb)
		else:
			var y_pos = rb.global_position.y
		# 查找区间
			for i in range(len(test_arr)):
				var start = test_arr[i][0]
				var end = test_arr[i][1]
				if y_pos >= start and y_pos < end:
					test_interval[i].append(rb)
					break
	for ar in test_interval:
		if ar.size() >= 36:
			for body in ar:
				body.get_node("..").destroy(body)
			score += 10
			score_text.text = str(score)

func _on_take_timeout():
	got_score()

var _start := false
func gameover():
	_start = false
	start_button.text = "Start"
	score = 0
	score_text.text = "0"
	next_texture.texture = null
	game_timer.stop()
	$"../take".stop()
	for child in get_children():
		child.queue_free()
	all_rigidbody = []

# 按钮功能
func _on_start_button_up():
	if _start:
		gameover()
	elif !_start:
		_start = true
		start_button.text = "End"
		game_timer.start()
		$"../take".start()
		block_creat()

func _on_pause_button_down():
	Pause_text.visible = !Pause_text.visible
	get_tree().paused = !get_tree().paused

func _on_esc_button_up():
	get_tree().change_scene_to_file("res://main/list.tscn")

# 功能
func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		Pause_text.visible = true
		get_tree().paused = true
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		Pause_text.visible = false
		get_tree().paused = false

func _ready():
	$"../End".connect("game_over",gameover)
	for i in range(21):
		var interval = [i * 32, (i + 1) * 32]
		test_arr.append(interval)
	test_arr.remove_at(0)
	test_arr.remove_at(0)

