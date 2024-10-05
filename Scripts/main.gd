extends Control

const Cell = preload("res://scenes/cell.tscn")

@export_enum("Human", "AI") var play_with : String = "Human"
const ai_mark = "O"
const human_mark = "X"
var cells : Array = []
var turn : int = 0

var ai = Minimax
var http_ai = http_node
@onready var http = $Node
var is_game_end : bool = false

var moves = []
var game = []
var player_moves = []
var mywin = preload("res://scenes/History.tscn")

#set up the board when the game first run
func _ready():
	set_up_history_window()
	for cell_count in range(9):
		setup_board()


func _on_cell_updated(cell):
	randomize()
	var board_state = getCurrentBoardState()
	var match_result = checkIfWinnerIsFound()
	
	add_player_move(board_state)
	if match_result:
		is_game_end = true
		add_match_result_to_DB(match_result)
	elif play_with == "AI" and turn == 1:
		moves.append({"player": str(player_moves[player_moves.size()-1])})
		moves.append(ai.minimax(board_state, ai_mark))
		
		var board = make_http_compatible(board_state)
		var make_request = http.request(board)
		await get_tree().create_timer(2.0).timeout
		var get_result = http.get_res()
		if(get_result == null):
			use_minimax_for_AI(board_state)
		else:
			cells[get_result["best_move"]].draw_cell()

func use_minimax_for_AI(board_state):
	cells[int(ai.minimax(board_state, ai_mark)["index"])].draw_cell()

func make_http_compatible(board):
	var get_curr = getCurrentBoardState()
	var res = {}
	for i in range(get_curr.size()):
		if(get_curr[i].casecmp_to("X") == 0 or get_curr[i].casecmp_to("O") == 0):
			res[str(i)] = get_curr[i]
		else:
			res[str(i)] = " "
	return res

func setup_board():
	var cell = Cell.instantiate()
	cell.main = self
	$Cells.add_child(cell)
	cells.append(cell)
	cell.cell_updated.connect(_on_cell_updated)

func getCurrentBoardState():
	var arr : Array = []
	for n in 9:
		if cells[n].cell_value == "":
			arr.append(str(n))
		else:
			arr.append(cells[n].cell_value)
	return arr

func checkIfWinnerIsFound():
	var match_result = check_match()
	return match_result

func check_match():
	for h in range(3):
		if cells[0+3*h].cell_value == "X" and cells[1+3*h].cell_value == "X" and cells[2+3*h].cell_value == "X":
			return ["X", 1+3*h, 2+3*h, 3+3*h]
	for v in range(3):
		if cells[0+v].cell_value == "X" and cells[3+v].cell_value == "X" and cells[6+v].cell_value == "X":
			return ["X", 1+v, 4+v, 7+v]
	if cells[0].cell_value == "X" and cells[4].cell_value == "X" and cells[8].cell_value == "X":
		return ["X", 1, 5, 9]
	elif cells[2].cell_value == "X" and cells[4].cell_value == "X" and cells[6].cell_value == "X":
		return ["X", 3, 5, 7]
	
	for h in range(3):
		if cells[0+3*h].cell_value == "O" and cells[1+3*h].cell_value == "O" and cells[2+3*h].cell_value == "O":
			return ["O", 1+3*h, 2+3*h, 3+3*h]
	for v in range(3):
		if cells[0+v].cell_value == "O" and cells[3+v].cell_value == "O" and cells[6+v].cell_value == "O":
			return ["O", 1+v, 4+v, 7+v]
	if cells[0].cell_value == "O" and cells[4].cell_value == "O" and cells[8].cell_value == "O":
		return ["O", 1, 5, 9]
	elif cells[2].cell_value == "O" and cells[4].cell_value == "O" and cells[6].cell_value == "O":
		return ["O", 3, 5, 7]
	
	var full = true
	for cell in cells:
		if cell.cell_value == "":
			full = false
	
	if full: return["Draw", 0, 0, 0]

func add_match_result_to_DB(match_result):
	for i in save_manager.read_save().size():
		#print(i)
		#print(save_manager.read_save()[i])
		game.append(save_manager.read_save()[i])
	if match_result[0] == "Draw":
		game.append(match_result[0])
	else:
		game.append("Winner: "+match_result[0])
	game.append(moves)
	save_manager.write_save('')
	save_manager.write_save(game)
	print(game)

func add_player_move(board_state):
	for i in board_state.size():
		if board_state[i] == "X" and not player_moves.has(i):
			player_moves.append(i)

func set_up_history_window():
	get_viewport().set_embedding_subwindows(false)
	var d = mywin.instantiate()
	add_child(d)
	d.visible = true
	d.position = Vector2(800, 800)
	d.title = "History"
	d.size = Vector2(300, 200)

func _on_restart_button_pressed():
	get_tree().reload_current_scene()

func start_win_animation(match_result: Array):
	var color: Color
	
	if match_result[0] == "X":
		color = Color.BLUE
	elif match_result[0] == "O":
		color = Color.RED
	
	for c in range(3):
		cells[match_result[c+1]-1].glow(color)


func _on_reset_db_pressed():
	save_manager.write_save([""])
	get_tree().reload_current_scene()
