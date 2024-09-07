extends TileMap

var forbidden = false

func _ready():
	board_chess.resize(9)
	board_chess.fill(Vector2i.ZERO)

signal decided(pick : Vector2i, setpos : Vector2i)
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and $"..".started:
			var temp = local_to_map(to_local(event.position))
			if !is_pick and get_cell_alternative_tile(0,temp) != -1:
				if player and temp.x > -5 and temp.x < -1:
					pick_chess(temp)
				elif !player and temp.x < 5 and temp.x > 1:
					pick_chess(temp)
			elif is_pick:
				if (temp == keeppos[0] or temp == keeppos[1]) and get_cell_alternative_tile(0,temp) != -1:
					set_cell(0, pickpos[0], 0, get_cell_atlas_coords(0,temp), 
						get_cell_alternative_tile(0,temp))
					set_cell(0, temp, 0, Vector2(0,0), -1)
					is_pick = false
				elif board.has(temp):
					if forbidden and temp == Vector2i.ZERO:
						return
					elif int(pickpos[2]/2) == board_chess[board.find(temp)].y + 1:
						forbidden = false
						set_cell(0, temp, 0, pickpos[1], pickpos[2])
						set_cell(0, keeppos[int(player)], 0, Vector2(0,0), -1)
						emit_signal("decided", pickpos[0], temp)
						is_pick = false
						update_board(pickpos[2], temp)

var player := true
const keeppos = [Vector2i(2,-2),Vector2i(-2,-2)]

var is_pick := false
var pickpos : Array = [Vector2i.ZERO, Vector2i.ZERO, 0]

func pick_chess(pos : Vector2i):
	pickpos = [pos, get_cell_atlas_coords(0,pos), get_cell_alternative_tile(0,pos)]
	set_cell(0, keeppos[int(player)], 0, get_cell_atlas_coords(0,pos), get_cell_alternative_tile(0,pos))
	set_cell(0, pos, 0, Vector2(0,0), -1)
	is_pick = true

func place(_pick, _set):
	var tempint = get_cell_alternative_tile(0, _pick)
	var tempvec = get_cell_atlas_coords(0, _pick)
	set_cell(0, _pick, 0, Vector2.ZERO, -1)
	set_cell(0, _set, 0, tempvec, tempint)
	update_board(tempint, _set)

const board = [Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
				Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0),
				Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1)]
var board_chess : Array[Vector2i] # Vector2(是否为玩家A,棋子大小)
func update_board(id : int, _pos : Vector2i):
	var posid = board.find(_pos)
	board_chess[posid].y = int(id/2)
	if int(id) & 1 == 0:
		board_chess[posid].x = 1
	else:
		board_chess[posid].x = 0
	check()

signal winner(playwin : bool) # 谁赢
const checkchess = [0, 1, 2, 3, 6]
const checkdir = [Vector2i(1,0), Vector2i(1,1), Vector2i(0,1), Vector2i(-1,1)]
func check():
	for i in checkchess:
		if board_chess[i].y == 0:
			continue
		var iid : int = board_chess[i].x
		for dir in checkdir:
			var icheck : Vector2i = board[i]
			var count = 1
			for a in range(2):
				icheck += dir
				if board.has(icheck) and board_chess[board.find(icheck)].y != 0 \
							and board_chess[board.find(icheck)].x == iid:
					count += 1
					if count == 3:
						emit_signal("winner", bool(iid))
						return
				else:
					break
