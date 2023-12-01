extends Control

var light_ability: String
var dark_ability: String

func _ready() -> void:
	UserAbilities.chosen_dark = ""
	UserAbilities.chosen_light = ""
	ScoreManager.reset_current_score()
	GameManager.reset_run_progress()
	$Control/Reset.hide()
	pass

func _on_button_pressed(ability_name: String, container_path: Node, ability_type: String) -> void:
	var button = container_path.get_node(ability_name.capitalize())
	button.self_modulate = Color.WEB_GRAY
	button.get_node("Outline").show()

	if ability_type == "light":
		light_ability = ability_name
		$Control/ChooseOneLight.hide()
	elif ability_type == "dark":
		dark_ability = ability_name
		$Control/ChooseOneDark.hide()

	# Disable other buttons in the same container
	var container = container_path
	for child in container.get_children():
		if child != button:
			child.disabled = true
			
	$Control/Reset.show()
	
	AudioManager.play_sfx("button_ability")
	
	if !light_ability.is_empty() and !dark_ability.is_empty():
		$CenterContainer/VBoxContainer/Start.modulate = Color.WHITE
		$CenterContainer/VBoxContainer/Start.modulate.a = 1
		$CenterContainer/VBoxContainer/Start.disabled = false

func _on_laser_pressed() -> void:
	_on_button_pressed("laser", $CenterContainer/VBoxContainer/Light, "light")

func _on_radiance_pressed() -> void:
	_on_button_pressed("radiance", $CenterContainer/VBoxContainer/Light, "light")

func _on_orb_pressed() -> void:
	_on_button_pressed("orb", $CenterContainer/VBoxContainer/Light, "light")

func _on_malady_pressed() -> void:
	_on_button_pressed("malady", $CenterContainer/VBoxContainer/Dark, "dark")

func _on_assassin_pressed() -> void:
	_on_button_pressed("assassin", $CenterContainer/VBoxContainer/Dark, "dark")

func _on_bomb_pressed() -> void:
	_on_button_pressed("bomb", $CenterContainer/VBoxContainer/Dark, "dark")

func _on_reset_pressed() -> void:
	get_tree().reload_current_scene()

func _change_info(body: String, heading: String, type: String) -> void:
	$Information.show()
	$Information/Container/AbilityName.text = heading
	$Information/Container/Text.text = body
	
	if type == "dark":
		$Information/Container/AbilityName.add_theme_color_override("font_color", Color('f48f8f'))
	elif type == "light":
		$Information/Container/AbilityName.add_theme_color_override("font_color", Color('ffedd9'))

func _on_laser_mouse_entered() -> void:
	_change_info("An incandescent beam of pure brilliance, scorching all deemed unworthy in its path.", "Beam of No'us", "light")

func _on_radiance_mouse_entered() -> void:
	_change_info("A surge of brilliant grace, empowering movement speed, attack speed, and granting periodic healing.", "Divine Celerity", "light")

func _on_orb_mouse_entered() -> void:
	_change_info("An ethereal cascade of opulent orbs. Every impact not only damages enemies but also heals the bearer.", "Opulence", "light")

func _on_malady_mouse_entered() -> void:
	_change_info("The ruthless expansion of miasmatic power, poisoning every enemy it touches.", "Plaguebearer", "dark")

func _on_assassin_mouse_entered() -> void:
	_change_info("An offering from the world below, instilling power that kills enemies instantly but feeds on health points.", "Offering's End", "dark")

func _on_bomb_mouse_entered() -> void:
	_change_info("An onslaught of explosive dark energies that obliterates enemies caught in it.", "Cataclysm", "dark")


func _on_start_pressed() -> void:
	UserAbilities.chosen_light = light_ability
	UserAbilities.chosen_dark = dark_ability
	Scenes.to_scene("res://scenes/levels/level.tscn")
	
	AudioManager.play_sfx("button_start")


func _on_home_pressed() -> void:
	light_ability = ""
	dark_ability = ""
	
	Scenes.to_scene("res://scenes/ui/start_menu.tscn")
