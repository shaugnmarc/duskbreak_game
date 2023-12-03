extends Node

const SAVE_PATH: String = "user://user_high_score.save"

var current_score: int = 0
var high_score: int = 0

signal score_loaded
signal score_saved

func reset_current_score() -> void:
	current_score = 0
	
func add_score(amount: int) -> void:
	current_score += amount
		
func save_high_score() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_var(high_score)
	print_rich("[color=green][b]Succesfully saved high score of [/b][/color]", high_score)
	save_file.close()
	
	if UserData.is_logged_in:
		SilentWolf.Scores.save_score(UserData.user_name, high_score)
		
	score_saved.emit()
	
func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var file_data = save_file.get_var(high_score)
		
		if file_data != null:
			high_score = file_data
		else:
			high_score = 0
		
		await get_tree().process_frame
		
		print_rich("[color=green][b]Succesfully loaded high score of [/b][/color]", high_score)
		save_file.close()
	else:
		high_score = 0
		print_rich("[color=red][b]File does not exist: ", SAVE_PATH, ". Setting high score to ", high_score)

	if UserData.is_logged_in:
		var sw_result = await SilentWolf.Scores.get_scores_by_player(UserData.user_name).sw_get_player_scores_complete
		var score_data = str(sw_result.scores)
		var jsonstr = JSON.parse_string(score_data)
		
		if sw_result.scores.size() > 0:
			high_score = jsonstr[0]["score"]
		else:
			high_score = 0
	
	score_loaded.emit()

func update_high_score(score: int) -> bool:
	await score_loaded
	
	print("ScoreManager -> Sending the ", high_score, " score to the request of method update_high_score()")
	
	if current_score > high_score:
		high_score = current_score

	save_high_score()

	return true
	
		
func get_high_score() -> int:
	load_high_score()
	
	await score_loaded

	print("ScoreManager -> Sending the ", high_score, " score to the request of method get_high_score()")
	return high_score
	
# Online leaderboard system and saving 

func _ready() -> void:
	UserData.new_user_register.connect(load_high_score)
	
	var api_path = FileAccess.open("res://private/api_key.txt", FileAccess.READ)
	var api_raw = api_path.get_as_text()
	var api = api_raw.replace("\n", "")


	SilentWolf.configure({
	"api_key": api,
	"game_id": "Duskbreak",
	"log_level": 1})

	SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/ui/start_menu.tscn"})
