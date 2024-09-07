extends Node

const PName = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

const gamelist = ["C3", "D3", "E3", "F3", "G3", "A3", "B3", 
				"C4", "D4", "E4", "F4", "G4", "A4", "B4", 
				"C5", "D5", "E5", "F5", "G5", "A5", "B5"] # 48-83 C4=1, +6
const gameplayer = [48, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67, 69, 
					71, 72, 74, 76, 77, 79, 81, 83]
const gamey = [300, 275, 250, 225, 200, 175, 150, 125, 100, 75, 50, 25, 
				0, -25, -50, -75, -100, -125, -150, -175, -200]

func parse_csv_file(path : String) -> Array:
	var csv_path = (OS.get_executable_path().get_base_dir() + "/data/" + path + ".csv").simplify_path()
	if path in "test":
		csv_path = "res://Res/test.csv"
	var file = FileAccess.open(csv_path,FileAccess.READ)
	if file:
		var temp : PackedStringArray = file.get_csv_line()
		var pack : PackedVector2Array = []
		while temp.size() == 2:
			var v : Vector2 = Vector2.ZERO
			v.x = clampi(int(temp[0]) + 6, 0, 20)
			v.y = float(temp[1])
			pack.append(v)
			temp = file.get_csv_line()
		return pack
	else:
		return []

func read_csvlist():
	var csv_path = (OS.get_executable_path().get_base_dir() + "/data").simplify_path()
	var dir = DirAccess.open(csv_path)
	var csv_file : PackedStringArray = ["test"]
	if dir:
		var templist = dir.get_files()
		for file in templist:
			if file.get_extension().to_upper() in "CSV":
				csv_file.append(file.get_basename())
	else:
		if !OS.is_debug_build():
			dir.make_dir(csv_path)
	return csv_file

