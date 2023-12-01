extends Control

const MILESTONE_SCREEN = preload("res://scenes/ui/milestone_screen.tscn")

@onready var level_node: Node2D = get_node("/root/Level")

var light_ability: String
var dark_ability: String

func _ready() -> void:
#	UserAbilities.chosen_dark = ""
#	UserAbilities.chosen_light = ""
#	ScoreManager.reset_current_score()
	AudioManager.play_sfx("milestone")
	show()
	$Control/Reset.hide()
	global_position.y -= 180
	
	var slide_tween: Tween = get_tree().create_tween()
	slide_tween.set_trans(Tween.TRANS_BACK)
	slide_tween.tween_property(self, "position:y", global_position.y + 180, 1.0)
	
	await slide_tween.step_finished
	
	get_tree().paused = true

func _on_button_pressed(ability_name: String, ability_type: String, node_path: TextureButton) -> void:
	var button = node_path
	button.get_node("Outline").show()

	if ability_type == "light":
		light_ability = ability_name
	elif ability_type == "dark":
		dark_ability = ability_name

	# Disable other buttons in EVERY container
	var container_light := $CenterContainer/VBoxContainer/Light
	var container_dark := $CenterContainer/VBoxContainer/Dark

	for child in container_light.get_children():
		if child != button:
			child.disabled = true
			child.modulate = Color.DARK_GRAY

	for child in container_dark.get_children():
		if child != button:
			child.disabled = true
			child.modulate = Color.DARK_GRAY
			
	$Control/Reset.show()
	
	if !light_ability.is_empty() or !dark_ability.is_empty():
		$CenterContainer/VBoxContainer/Start.modulate = Color.WHITE
		$CenterContainer/VBoxContainer/Start.modulate.a = 1
		$CenterContainer/VBoxContainer/Start.disabled = false

func _on_laser_pressed() -> void:
	_on_button_pressed("laser", "light", $CenterContainer/VBoxContainer/Light/Laser)

func _on_radiance_pressed() -> void:
	_on_button_pressed("radiance", "light", $CenterContainer/VBoxContainer/Light/Radiance)

func _on_orb_pressed() -> void:
	_on_button_pressed("orb", "light", $CenterContainer/VBoxContainer/Light/Orb)

func _on_malady_pressed() -> void:
	_on_button_pressed("malady", "dark", $CenterContainer/VBoxContainer/Dark/Malady)

func _on_assassin_pressed() -> void:
	_on_button_pressed("assassin", "dark", $CenterContainer/VBoxContainer/Dark/Assassin)

func _on_bomb_pressed() -> void:
	_on_button_pressed("bomb", "dark", $CenterContainer/VBoxContainer/Dark/Bomb)

func _on_reset_pressed() -> void:
	var container_light := $CenterContainer/VBoxContainer/Light
	var container_dark := $CenterContainer/VBoxContainer/Dark

	for child in container_light.get_children():
		child.disabled = false
		child.modulate = Color.WHITE
		child.get_node("Outline").hide()

	for child in container_dark.get_children():
		child.disabled = false
		child.modulate = Color.WHITE
		child.get_node("Outline").hide()
			
	$Control/Reset.hide()
	
	light_ability = ""
	dark_ability = ""
	
	if !light_ability.is_empty() or !dark_ability.is_empty():
		$CenterContainer/VBoxContainer/Start.modulate = Color.WHITE
		$CenterContainer/VBoxContainer/Start.modulate.a = 1
		$CenterContainer/VBoxContainer/Start.disabled = false
	else:
		$CenterContainer/VBoxContainer/Start.modulate = Color.DARK_GRAY
		$CenterContainer/VBoxContainer/Start.modulate.a = 0.50
		$CenterContainer/VBoxContainer/Start.disabled = true

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
	if !light_ability.is_empty():
		UserAbilities.select_light(light_ability)
	elif !dark_ability.is_empty():
		UserAbilities.select_dark(dark_ability)
	
	get_tree().paused = false
	
	AudioManager.play_sfx("button")
	
	await get_tree().process_frame
	
	level_node.force_kill()
	
	queue_free()
