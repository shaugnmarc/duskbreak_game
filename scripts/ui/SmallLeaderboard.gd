extends TextureRect

const ScoreItem = preload("res://addons/silent_wolf/Scores/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var list_index = 0
# Replace the leaderboard name if you're not using the default leaderboard
var ld_name = "main"
var max_scores = 0


func _ready():
	$AccessData/Register.disabled = true
	$AccessData/Login.disabled = true
	
	UserData.finished_load.connect(_on_data_loaded)
	ScoreManager.score_loaded.connect(_on_score_loaded)
	
	_on_data_loaded()
	
	print("SilentWolf.Scores.leaderboards: " + str(SilentWolf.Scores.leaderboards))
	print("SilentWolf.Scores.ldboard_config: " + str(SilentWolf.Scores.ldboard_config))
	var scores = SilentWolf.Scores.scores
	#var scores = []
	if ld_name in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[ld_name]
	var local_scores = SilentWolf.Scores.local_scores
	
	if len(scores) > 0: 
		render_board(scores, local_scores)
	else:
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
		add_loading_scores_message()
		var sw_result = await SilentWolf.Scores.get_scores().sw_get_scores_complete
		scores = sw_result.scores
		hide_message()
		render_board(scores, local_scores)


func _on_data_loaded() -> void:

	if UserData.is_registered:
		$AccessData/Register.disabled = true
	else:
		$AccessData/Register.disabled = false
		
	if UserData.is_logged_in:
		$AccessData/Login.disabled = true
	else:
		$AccessData/Login.disabled = false
		
	if UserData.user_name != "":
		$AccessData.hide()
		$ShowData.show()
		$ShowData/Username.text = UserData.user_name

		$ShowData/Score.text = str(await ScoreManager.get_high_score())
	else:
		$AccessData.show()
		$ShowData.hide()
		$ShowData/Username.text = "ErrorAUTH"
		$ShowData/Score.text = "<null>"
		
func _on_score_loaded() -> void:
	pass

func render_board(scores: Array, local_scores: Array) -> void:
	var all_scores = scores
	if ld_name in SilentWolf.Scores.ldboard_config and is_default_leaderboard(SilentWolf.Scores.ldboard_config[ld_name]):
		all_scores = merge_scores_with_local_scores(scores, local_scores, max_scores)
		if scores.is_empty() and local_scores.is_empty():
			add_no_scores_message()
	else:
		if scores.is_empty():
			add_no_scores_message()
	if all_scores.is_empty():
		for score in scores:
			add_item(score.player_name, str(int(score.score)))
	else:
		for score in all_scores:
			add_item(score.player_name, str(int(score.score)))


func is_default_leaderboard(ld_config: Dictionary) -> bool:
	var default_insert_opt = (ld_config.insert_opt == "keep")
	var not_time_based = !("time_based" in ld_config)
	return default_insert_opt and not_time_based


func merge_scores_with_local_scores(scores: Array, local_scores: Array, max_scores: int=10) -> Array:
	if local_scores:
		for score in local_scores:
			var in_array = score_in_score_array(scores, score)
			if !in_array:
				scores.append(score)
			scores.sort_custom(sort_by_score);
	if scores.size() > max_scores:
		var new_size = scores.resize(max_scores)
	return scores


func sort_by_score(a: Dictionary, b: Dictionary) -> bool:
	if a.score > b.score:
		return true;
	else:
		if a.score < b.score:
			return false;
		else:
			return true;


func score_in_score_array(scores: Array, new_score: Dictionary) -> bool:
	var in_score_array =  false
	if !new_score.is_empty() and !scores.is_empty():
		for score in scores:
			if score.score_id == new_score.score_id: # score.player_name == new_score.player_name and score.score == new_score.score:
				in_score_array = true
	return in_score_array


func add_item(player_name: String, score_value: String) -> void:
	var score_container = $CenterContainer/Elements/ScoreContainer
	var item = ScoreItem.instantiate()

	if score_container.get_child_count() < 10:
		score_container.add_child(item)
		list_index += 1
	
	item.get_node("PlayerName").text = str(list_index) + str(". ") + player_name
	item.get_node("Score").text = score_value
	item.offset_top = list_index * 100


func add_no_scores_message() -> void:
	var item = $CenterContainer/Elements/Message
	item.text = "No scores yet!"
	item.show()

func add_loading_scores_message() -> void:
	var item = $CenterContainer/Elements/Message
	item.text = "Loading scores..."
	item.show()

func hide_message() -> void:
	$CenterContainer/Elements/Message.hide()


func _on_login_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/login_screen.tscn")
	AudioManager.play_sfx("button")

func _on_register_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/register_screen.tscn")
	AudioManager.play_sfx("button")


func _on_refresh_pressed() -> void:
	var score_container = $CenterContainer/Elements/ScoreContainer
	
	for child in score_container.get_children():
		if is_instance_valid(child):
			child.queue_free()
			
	list_index = 0

	var scores = SilentWolf.Scores.scores
	#var scores = []
	if ld_name in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[ld_name]

	var local_scores = SilentWolf.Scores.local_scores
	add_loading_scores_message()
	var sw_result = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	scores = sw_result.scores
	hide_message()
	render_board(scores, local_scores)
