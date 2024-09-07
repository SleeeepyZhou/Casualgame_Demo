extends TileMap

# x位分奇偶判定方向
const DIREVEN = [Vector2(0,-1), Vector2(1,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(-1,-1)]
const DIRODD = [Vector2(0,-1), Vector2(1,0), Vector2(1,1), Vector2(0,1), Vector2(-1,1), Vector2(-1,0)]

signal decided(isplace : bool, setpos : Vector2)

# 处理鼠标输入
var player_identity : int = 2
var decid := false # 禁止确定后继续操作

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and !decid:
			var temp = local_to_map(to_local(event.position))
			if get_cell_alternative_tile(0, temp) == 1:
				rotated = false
				emit_signal("decided", true, temp)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and !rotated and !decid:
			var temp = local_to_map(to_local(event.position))
			if get_cell_alternative_tile(0, temp) == player_identity:
				emit_signal("decided", false, temp)

const posran = [7,6,5,4]
func posbool(pos : Vector2) -> bool:
	if abs(pos.x) > 7:
		return false
	var i : int = int(abs(pos.x) / 2)
	return (int(pos.x) & 1 == 0 and abs(pos.y) <= posran[i]) or \
			(pos.y == -posran[i] or abs(pos.y) < posran[i])

# 同时处理输入，放置与旋转，放置的优先级较旋转高，handle为true则为落子。返回是否出现胜利以及胜利分差（A-B）
var hole := []
var rotated := false # 同时旋转禁一次，落子后解禁
func place_chess(handleA : bool, playerA : Vector2, handleB : bool, playerB : Vector2) -> Array:
	decid = false
	# 同时落子
	if handleA and handleB:
		# 同一位置
		if playerA == playerB:
			set_cell(0, playerA, 0, Vector2(2,0), 4)
			hole.append(playerA)
			return [false]
		# 不同位置
		set_cell(0, playerA, 0, Vector2(2,0), 2)
		var Are = check_win(playerA)
		set_cell(0, playerB, 0, Vector2(2,0), 3)
		var Bre = check_win(playerB)
		var A : int = Are[0]
		var B : int = Bre[0]
		if A > 0 or B > 0: # 出现赢家
			var Apiece = Are[1]
			var Bpiece = Bre[1]
			return [true, A - B, Apiece, Bpiece]
		else:
			return [false]
	# 同时旋转
	elif !handleA and !handleB:
		rotated = true
		return [false]
	# 旋转落子
	else:
		var result := []
		if handleA:
			result = rota(playerB, playerA, 2)
		elif handleB:
			result = rota(playerA, playerB, 3)
		return result

func rota(roter : Vector2, place : Vector2, color : int):
	# 落子
	set_cell(0, place, 0, Vector2(2,0), color)
	var rcolor : int
	if color == 2:
		rcolor = 3
	else:
		rcolor = 2
	set_cell(0, roter, 0, Vector2(2,0), rcolor)
	# 旋转
	var dir := []
	var rdir := []
	var colortemp := []
	if int(roter.x) & 1 == 0: # x为偶
		dir = DIREVEN.duplicate()
	else:
		dir = DIRODD.duplicate()
	dir = dir.map(func(i): return i + roter)
	colortemp = dir.map(func(i): return get_cell_alternative_tile(0, i))
	for i in range(dir.size()):
		rdir.append(dir[i-dir.size()+1])
		set_cell(0, rdir[i], 0, Vector2(2,0), colortemp[i])
	# 检查
	if !dir.has(place):
		rdir.append(place)
	var Awin : int
	var Bwin : int
	var Apiece := []
	var Bpiece := []
	var win := false
	for chess in rdir:
		if get_cell_alternative_tile(0, chess) == 2:
			var temp = check_win(chess)
			if !is_subset(temp[1], Apiece):
				Awin += temp[0]
				Apiece += temp[1]
		elif get_cell_alternative_tile(0, chess) == 3:
			var temp = check_win(chess)
			if !is_subset(temp[1], Bpiece):
				Bwin += temp[0]
				Bpiece += temp[1]
	if Awin > 0 or Bwin > 0:
		win = true # 出现赢家
		Apiece = remove_duplicate(Apiece)
		Bpiece = remove_duplicate(Bpiece)
	return [win, Awin - Bwin, Apiece, Bpiece]

func is_subset(sub : Array, superset : Array) -> bool:
	for elem in sub:
		if !superset.has(elem):
			return false
	return true
func remove_duplicate(origin : Array) -> Array:
	var temp := []
	for i in origin:
		if !temp.has(i):
			temp.append(i)
	return temp

# 胜利涂色
func winner(awinp : Array, bwinp : Array):
	decid = true
	for i in awinp:
		set_cell(0, i, 0, Vector2(2,0), 10)
	for i in bwinp:
		set_cell(0, i, 0, Vector2(2,0), 11)

# 检测chess点是否造成胜利，返回胜利点数和胜利棋子坐标数组的两元素数组
@export var win_condition : int = 5
func check_win(chess : Vector2) -> Array:
	var chess_color := get_cell_alternative_tile(0, chess)
	var score : int = 0
	var winchess := []
	for i in range(3):
		var line : int = 0
		var check1 := check(chess,i,chess_color)
		var check2 := check(chess,i+3,chess_color)
		line += check1[0] + 1
		line += check2[0]
		if line >= win_condition:
			score += line - win_condition + 1
			winchess += (check1[1]+check2[1]+[chess])
	if !winchess.is_empty():
		winchess = remove_duplicate(winchess)
	return [score, winchess]
func check(chess : Vector2, i : int, chess_color : int) -> Array:
	var temp = chess
	var line : int = 0
	var temparr := []
	var s := true
	while s:
		if int(temp.x) & 1 == 0: # x为偶
			temp += DIREVEN[i]
		else:
			temp += DIRODD[i]
		if get_cell_alternative_tile(0, temp) == chess_color:
			line += 1
			temparr.append(temp)
		else:
			s = false
	return [line,temparr]
