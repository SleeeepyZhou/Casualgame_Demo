extends Control

var knock : Array = [preload("res://Lib/tool/Knock1G.wav"), preload("res://Lib/tool/Knock2G.wav"),
		preload("res://Lib/tool/Knock3.wav"), preload("res://Lib/tool/Knock1.wav"), 
		preload("res://Lib/tool/Knock2.wav")]
const GOOD = 1

var score : int = 0:
	set(i):
		var add = i - score
		score = i
		$Score.text = "瓜德: " + str(i)
		$Player.stream = knock[last_p]
		$Player.play()
		$Animation.play("Knock")
		var addtext = Label.new()
		addtext.text = "瓜德 " + str(add)
		$Watermelon/Box.add_child(addtext)
		addtext.position.x = -20
		var tween = get_tree().create_tween()
		tween.tween_property(addtext, "position", Vector2(-20,-80), 0.5)
		tween.tween_property(addtext, "modulate", Color.TRANSPARENT, 0.3)
		tween.tween_callback(addtext.queue_free)
		times += 1
		if times > 12:
			broken = true

func _on_watermelon_gui_input(event):
	if !broken and event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		score += 1
func _on_watermelon_body_entered(body):
	if !broken:
		score += 1

var times : int = 0
func _on_timer_timeout():
	times = 0
var broken_v = preload("res://Lib/tool/TM.wav")
var broken_t = Image.load_from_file("res://Res/watermelon(broken).png")
var broken := false:
	set(b):
		broken = b
		if b:
			$Watermelon/Collision/Broken.visible = true
			$Player.stream = broken_v
			$Player.play()
			await get_tree().create_timer(3).timeout
			$Watermelon/Collision/Broken.visible = false
			broken = false
			guess = [false, false]

var last_p : int = randi()%3:
	get:
		if guess[0]:
			last_p = randi()%3
			guess = [false, false]
		return last_p
var guess : Array[bool] = [false, false]:
	set(b):
		if !broken and b[0]:
			var last := false
			if last_p < GOOD + 1:
				last = true
			if last == guess[1]:
				score += 5
			else:
				score -= 5
		guess = b
func _on_bad_pressed():
	guess = [true, false]
func _on_good_pressed():
	guess = [true, true]

var picked := false:
	set(b):
		picked = b
		$Mallet.visible = b
		$Watermelon.monitoring = b
		$MalletTex.visible = !b
func _on_mallet_tex_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		picked = true
func _on_gui_input(event):
	if picked and event is InputEventMouseButton and \
			event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		picked = false

func _on_tip_mouse_entered():
	$Tip/Box.visible = true
func _on_tip_mouse_exited():
	$Tip/Box.visible = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
