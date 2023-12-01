extends CanvasLayer

@onready var light_bar := $Components/AbilityLightBar
@onready var dark_bar := $Components/AbilityDarkBar
@onready var shockwave_anim := $Effects/Shockwave/AnimationPlayer

var player_node: CharacterBody2D
var player_energy: Node2D
var player_ability: Node2D
var player_health: Node2D

var light_ability_icons := {"laser": "res://assets/ui/ability/light_laser.png",
							"radiance": "res://assets/ui/ability/light_radiance.png",
							"orb": "res://assets/ui/ability/light_orb.png"}
var dark_ability_icons := {"malady": "res://assets/ui/ability/dark_malady.png",
							"assassin": "res://assets/ui/ability/dark_assassin.png",
							"bomb": "res://assets/ui/ability/dark_bomb.png"}

func _ready() -> void:
	ScreenManager.hud = self
	UserAbilities.abilities_changed.connect(_apply_ability_tex)
	
	player_node = get_parent().get_node_or_null("Player")
	
	if is_instance_valid(player_node):
		player_energy = player_node.get_node_or_null("EnergyManager")
		player_ability = player_node.get_node_or_null("AbilityManager")
		player_health = player_node.get_node_or_null("HealthManager")
		
	else:
		return
		
	if is_instance_valid(player_ability):
		player_ability.dark_attack_start.connect($Effects.start_shockwave)
	else:
		return
		
	if is_instance_valid(player_health):
		$Components/HealthBar.value = player_health.current_health
	else:
		return
		
	_apply_ability_tex()
	
	
func _apply_ability_tex() -> void:
	light_bar.get_node("AbilityLight").texture = load(light_ability_icons[UserAbilities.chosen_light])
	dark_bar.get_node("AbilityDark").texture = load(dark_ability_icons[UserAbilities.chosen_dark])
	
func _process(delta: float) -> void:
	if is_instance_valid(player_energy):
		light_bar.value = player_energy.light_energy
		dark_bar.value = player_energy.dark_energy
		
		if player_energy.light_energy < player_energy.MAX_ENERGY:
			light_bar.get_node("AbilityLight").modulate = Color.DIM_GRAY
		else:
			light_bar.get_node("AbilityLight").modulate = Color.WHITE
		
		if player_energy.dark_energy < player_energy.MAX_ENERGY:
			dark_bar.get_node("AbilityDark").modulate = Color.DIM_GRAY
		else:
			dark_bar.get_node("AbilityDark").modulate = Color.WHITE
			
		if !player_ability.can_skill_light:
			light_bar.get_node("AbilityLight").modulate = Color.DIM_GRAY
		else:
			light_bar.get_node("AbilityLight").modulate = Color.WHITE

		if !player_ability.can_skill_dark:
			dark_bar.get_node("AbilityDark").modulate = Color.DIM_GRAY
		else:
			dark_bar.get_node("AbilityDark").modulate = Color.WHITE
		
	
	if is_instance_valid(player_health):
		var new_health: int = player_health.current_health
		var healthbar_value: int = $Components/HealthBar.value
		if healthbar_value != new_health:
			var tween: Tween = get_tree().create_tween()
			tween.tween_property($Components/HealthBar, "value", new_health, 0.3)
		
	
	$ComponentsRight/ScoreNumber.text = str(ScoreManager.current_score)

func _on_home_pressed() -> void:
	if !$PauseScreen/CenterContainer.visible:
		$PauseScreen/CenterContainer.show()
		get_tree().paused = true
	else: 
		$PauseScreen/CenterContainer.hide()
