extends Control

var light_ability_name: String
var dark_ability_name: String

func _ready() -> void:
	
	match UserAbilities.chosen_light:
		"laser":
			light_ability_name = "Beam of No'us"
		"radiance":
			light_ability_name = "Divine Celerity"
		"orb":
			light_ability_name = "Opulence"
			
	match UserAbilities.chosen_dark:
		"malady":
			dark_ability_name = "Plaguebearer"
		"assassin":
			dark_ability_name = "Offering's End"
		"bomb":
			dark_ability_name = "Cataclysm"

	$CenterContainer.global_position.x -= 320 
	
	var tween: Tween = get_tree().create_tween()
	
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property($CenterContainer, "global_position:x", $CenterContainer.global_position.x + 320, 1.0)

	$CenterContainer/TextureRect/Header/HBoxContainer/Container/LightAbility.text = light_ability_name
	$CenterContainer/TextureRect/Header/HBoxContainer/Container/DarkAbility.text = dark_ability_name
	
	$CenterContainer/TextureRect/CenterContainer/VBoxContainer/MainLabel/ScoreValues/ScoreValue.text = str(ScoreManager.current_score)
	
	$CenterContainer/TextureRect/CenterContainer/VBoxContainer/MainLabel/ScoreValues/HighScoreValue.text = str(ScoreManager.current_score)
	
	GameManager.reset_run_progress()
	AudioManager.stop_music()
	AudioManager.play_sfx("end_screen")
	ScoreManager.load_high_score()
	ScoreManager.update_high_score(ScoreManager.current_score)
	await get_tree().process_frame
	
	_display_accessed_high_score()


func _display_accessed_high_score() -> void:
	$CenterContainer/TextureRect/CenterContainer/VBoxContainer/MainLabel/ScoreValues/HighScoreValue.text = str(await ScoreManager.get_high_score())
	ScoreManager.reset_current_score()

func _on_back_home_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/start_menu.tscn")
	AudioManager.play_sfx("button")
	AudioManager.play_music("menu")

func _on_back_ability_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/select_menu.tscn")
	AudioManager.play_sfx("button")
	AudioManager.play_music("menu")
