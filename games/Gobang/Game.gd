extends Control

# 网络相关
func _on_create_ok_pressed():
	var peer = ENetMultiplayerPeer.new()
	if peer.create_server(int($Create/Control/HostPort.value)) == OK:
		$Disconnect/ConnectState.text = "You are creater"
		$Jion.visible = false
		start(player)
	self.multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(client_connected)

func _on_jion_ok_pressed():
	var peer = ENetMultiplayerPeer.new()
	if peer.create_client($Jion/Control/JionIP.text,int($Jion/Control/JionPort.value)) == OK:
		$Disconnect/ConnectState.text = "Connected"
		$Create.visible = false
	self.multiplayer.multiplayer_peer = peer

func client_connected(id: int):
	$Disconnect/ConnectState.text = "Someone connected"
	started = true
	rpc("ready_game",!player)

func _on_disconnect_pressed():
	started = false
	self.multiplayer.multiplayer_peer.close()
	$Disconnect/ConnectState.text = "Unconnected"
	$Create.visible = true
	$Jion.visible = true
	if player:
		$B/BButton.visible = true
	else:
		$A/AButton.visible = true


# 联系方法

# 初始化
var player := true
var started := false
@onready var current_board = $Checkerboard
func start(ac_player : bool):
	player = ac_player
	player_deci()
	$A/AButton.visible = false
	$B/BButton.visible = false
	$"../Text".visible = false
	current_board.queue_free()
	var board = load("res://games/Gobang/Checkerboard.tscn").instantiate()
	board.scale = Vector2(0.5,0.5)
	board.name = "Checkerboard"
	add_child(board)
	board.position = Vector2(-25, -25)
	board.connect("decided",is_decided)
	current_board = board
	a_handle = false
	a_set = Vector2.ZERO
	b_handle = false
	b_set = Vector2.ZERO
	if player:
		return
	else:
		board.player_identity = 3

@rpc # 客户端初始化，客户端运行
func ready_game(ac_player : bool):
	started = true
	start(ac_player)

# Game
var a_handle : bool
var a_set : Vector2
var b_handle : bool
var b_set : Vector2
@onready var Aoklabel = $A/ColorRect/OKLabel
@onready var Boklabel = $B/ColorRect/OKLabel

func is_decided(isplace : bool, setpos : Vector2): # 落子确认
	if started:
		current_board.decid = true
		current_board.set_cell(0, setpos, 0, Vector2(0,0), 6)
		if player:
			Aoklabel.visible = true
			a_handle = isplace
			a_set = setpos
		elif !player:
			Boklabel.visible = true
			b_handle = isplace
			b_set = setpos
		rpc("send_handle",isplace,setpos)

@rpc("any_peer","call_remote") # 发信
func send_handle(handle : bool, pos : Vector2):
	if !player:
		Aoklabel.visible = true
		a_handle = handle
		a_set = pos
	elif player:
		Boklabel.visible = true
		b_handle = handle
		b_set = pos

@rpc("authority","call_local") # 回合结算，双方同时
func accept_results():
	Aoklabel.visible = false
	Boklabel.visible = false
	var result : Array
	result = current_board.place_chess(a_handle,a_set,b_handle,b_set)
	if result[0]:
		current_board.winner(result[2], result[3])
		started = false
		$"../Text".visible = true
		if result[1] > 0:
			$"../Text".text = "PlayerA win " + str(result[1])
		elif result[1] == 0:
			$"../Text".text = "Draw"
		else:
			$"../Text".text = "PlayerB win " + str(-result[1])

func _process(delta):
	if Aoklabel.visible and Boklabel.visible and multiplayer.is_server():
		rpc("accept_results")


# 界面相关
var ip_list := []
func _on_create_pressed():
	ip_list = []
	for address in IP.get_local_addresses():
		if address.split('.').size() == 4:
			ip_list.append(address)
	$Create/Control/HostIP/IPlist.max_value = ip_list.size() - 1
	$Create/Control/HostIP.text = ip_list[0]
	$Create/Control.visible = !$Create/Control.visible

func _on_iplist_value_changed(value):
	$Create/Control/HostIP.text = ip_list[value]

func _on_jion_pressed():
	$Jion/Control.visible = !$Jion/Control.visible

func player_deci():
	if player:
		$A/Label.visible = true
		$A/AButton.visible = false
		$B/Label.visible = false
		$B/BButton.visible = true
	elif !player:
		$A/Label.visible = false
		$A/AButton.visible = true
		$B/Label.visible = true
		$B/BButton.visible = false

func _on_a_button_pressed():
	player = true
	player_deci()

func _on_b_button_pressed():
	player = false
	player_deci()

func _on_esc_button_up():
	get_tree().change_scene_to_file("res://main/list.tscn")

func _on_restart_button_up():
	start(player)
