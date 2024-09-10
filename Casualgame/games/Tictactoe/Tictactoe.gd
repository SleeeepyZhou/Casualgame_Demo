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

func _on_disconnect_button_up():
	started = false
	self.multiplayer.multiplayer_peer.close()
	$Disconnect/ConnectState.text = "Unconnected"
	$Create.visible = true
	$Jion.visible = true
	if player:
		$B/BButton.visible = true
	else:
		$A/AButton.visible = true

var player := true
var started := false
@onready var current_board : TileMap = $Board
func start(ac_player : bool):
	player = ac_player
	$A/AButton.visible = false
	$B/BButton.visible = false
	$"../Text".visible = false
	current_board.queue_free()
	var board = load("res://games/Tictactoe/board.tscn").instantiate()
	add_child(board)
	board.position = Vector2(-40, -40)
	board.connect("decided",is_decided)
	board.connect("winner",is_win)
	current_board = board
	if !player:
		board.player = false
		current_board.set_process_input(false)
	else:
		current_board.forbidden = true

@rpc # 客户端初始化，客户端运行
func ready_game(ac_player : bool):
	started = true
	start(ac_player)

func is_win(playwin : bool):
	iready = false
	othready = false
	started = false
	current_board.set_process_input(false)
	$"../Text".visible = true
	if playwin:
		$"../Text".text = "PlayerA win"
	else:
		$"../Text".text = "PlayerB win"

func is_decided(pickpos : Vector2, setpos : Vector2):
	if started:
		current_board.set_process_input(false)
		rpc("placechess", pickpos, setpos)

@rpc("any_peer")
func placechess(_pick : Vector2i, _set : Vector2):
	current_board.set_process_input(true)
	current_board.place(_pick, _set)

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

var iready := false
var othready := false
func _on_restart_button_up():
	iready = true
	start(player)
	rpc("restart")
	if othready:
		started = true

@rpc("any_peer")
func restart():
	othready = true
	if iready:
		started = true

func _on_help_mouse_entered():
	$Help/Label.visible = true

func _on_help_mouse_exited():
	$Help/Label.visible = false
