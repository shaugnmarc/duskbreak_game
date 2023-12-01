extends Node2D

const SPD_BOOST: int = 50
const ATK_SPD_BOOST: float = 0.5
const HEAL_TIMES: int = 8
const INSTA_KILL: int = 200

@onready var light_abilty: String = UserAbilities.chosen_light
@onready var dark_ability: String = UserAbilities.chosen_dark

@onready var player_node: Player = get_parent()
@onready var camera: Camera2D = get_node_or_null("/root/Level/Camera2D")
@onready var player_sprite := %AnimatedSprite2D
@onready var energy_manager: PlayerEnergy = %EnergyManager
@onready var health_manager: Node2D = %HealthManager
@onready var shockwave_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var fx_sprite: AnimatedSprite2D = %EffectsSprite2D

signal dark_attack_start

var viewport_pos: Vector2
var can_skill_light := true
var can_skill_dark := true
var projectile_scene = preload("res://scenes/abilities/light_projectile.tscn")
var bomb_scene = preload("res://scenes/vfx/dark_explosion.tscn")

func _ready() -> void:
	shockwave_collision.disabled = true
	shockwave_collision.scale = Vector2.ZERO 
	
	UserAbilities.abilities_changed.connect(_update_abilities)

func _update_abilities() -> void:
	light_abilty = UserAbilities.chosen_light
	dark_ability = UserAbilities.chosen_dark

func _physics_process(delta: float) -> void:
	if !energy_manager.light_maxed:
		can_skill_light = false
	else:
		can_skill_light = true
		
	if !energy_manager.dark_maxed:
		can_skill_dark = false
	else:
		can_skill_dark = true
	# Converts the player's global pos to its position in the viewport
	var raw_viewport_pos: Vector2 = player_node.get_global_transform_with_canvas().get_origin()
	viewport_pos = Vector2(raw_viewport_pos.x / get_viewport_rect().size.x, raw_viewport_pos.y / get_viewport_rect().size.y)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ability") and can_skill_light:
		if energy_manager.light_maxed:
			light_attack(light_abilty)
			energy_manager.empty_value("light")
	if event.is_action_pressed("second_ability") and can_skill_dark:
		if energy_manager.dark_maxed:
			dark_attack(dark_ability)
			energy_manager.empty_value("dark")

#func reset_player() -> void:
#	$LightRadianceIdle.emitting = false
#	$DarkAuraIdle.emitting = false
#	player_node.light_state = false
#	player_node.dark_state = false
	
func light_attack(type: String) -> void:
	energy_manager.empty_value("light")
	match type:

		"laser":
			if player_node.is_attacking and player_sprite.is_playing():
				await player_sprite.animation_finished
				print("Player is still attacking, recalling method...")
				light_attack(type)
			else:
				_toggle_skill_availability("light")
				_toggle_skill_availability("dark")
				
				var laser_scene := preload("res://scenes/abilities/laser_beam.tscn")
				var laser_instance = laser_scene.instantiate()
				add_child(laser_instance)
				
				await get_tree().process_frame
				
				laser_instance.toggle_laser(true)
				player_node.flip_based_on_mouse = true
				player_node.is_beaming = true
				
				await get_tree().create_timer(10.0).timeout
				
				laser_instance.toggle_laser(false)
				player_node.flip_based_on_mouse = false
				player_node.is_beaming = false
				
				await get_tree().create_timer(1.0).timeout
				
				laser_instance.queue_free()
				_toggle_skill_availability("light")
				_toggle_skill_availability("dark")

		"radiance":
			_toggle_skill_availability("light")
			
			fx_sprite.z_index = 1
			ScreenManager.shake_camera(2.0)
			AudioManager.play_sfx("light_radiance")
			fx_sprite.play("radiance_new")
			$LightRadianceIdle.emitting = true
			await fx_sprite.animation_finished
			fx_sprite.z_index = 0
			
			
			player_node.current_speed += SPD_BOOST
			player_node.attack_speed += ATK_SPD_BOOST
			player_node.light_state = true
			
			await get_tree().physics_frame
			
			for i in range(HEAL_TIMES):
				health_manager.heal(7)
				await get_tree().create_timer(20 / float(HEAL_TIMES)).timeout

			_toggle_skill_availability("light")
			
			player_node.current_speed -= SPD_BOOST
			player_node.attack_speed -= ATK_SPD_BOOST
			player_node.light_state = false
			$LightRadianceIdle.emitting = false

		"orb":
			var projectile_number: int = 10
			
			fx_sprite.play("orb")
			AudioManager.play_sfx("charge_up", 0.0, 4.0)
			await fx_sprite.animation_finished
			
			ScreenManager.shake_camera(2.0)

			for i in range(projectile_number):
				var projectile = projectile_scene.instantiate()
				var angle = deg_to_rad(i * 360 / projectile_number)  # Calculate angle in radians (360 degrees / 24 projectiles)
				var direction = Vector2(cos(angle), sin(angle)).normalized()
				projectile.global_position = global_position  # Set the initial position
				projectile.shoot_in_direction(direction)
				get_parent().get_parent().add_child(projectile)
			
			AudioManager.play_sfx("light_orb")

func dark_attack(type: String) -> void:
	energy_manager.empty_value("dark")
	match type:
		"malady":
			fx_sprite.play_backwards("dark_charge")
			AudioManager.play_sfx("charge_up")
			await fx_sprite.animation_finished
			
			fx_sprite.play("dark_erupt")
			
			await get_tree().create_timer(0.25).timeout
			
			dark_attack_start.emit(viewport_pos)
			ScreenManager.shake_camera(20.0)
			AudioManager.play_sfx("dark_malady_expand")
			AudioManager.play_sfx("dark_malady_remnant")
			_toggle_skill_availability("dark")
			
			shockwave_collision.scale = Vector2.ZERO
			shockwave_collision.disabled = false
			var tween = get_tree().create_tween()
			tween.tween_property(shockwave_collision, "scale", Vector2(1, 1), 2.0)
			await tween.step_finished
			shockwave_collision.disabled = true
			shockwave_collision.scale = Vector2.ZERO

			_toggle_skill_availability("dark")

		"bomb":
			var bomb_count: int = 50
			
			camera.change_mood(true)
			fx_sprite.play_backwards("dark_charge")
			AudioManager.play_sfx("dark_bomb_alarm")
			
			_toggle_skill_availability("dark")
			_toggle_skill_availability("light")
			
			await get_tree().create_timer(1.5).timeout
			
			for i in range(bomb_count):
				AudioManager.play_sfx("dark_bomb")
				var min_camera_area: Vector2 = ScreenManager.screen_camera.global_position + Vector2(64, 0)
				var max_camera_area: Vector2 = ScreenManager.screen_camera.global_position + Vector2(256, 180)
				var bomb: AnimatedSprite2D = bomb_scene.instantiate()
				
				bomb.global_position = Vector2(randf_range(min_camera_area.x, max_camera_area.x),
				randf_range(min_camera_area.y, max_camera_area.y))
				get_node("/root/Level").add_child(bomb)
#				min_camera_area.y -= 2
#				max_camera_area.y -= 2
				
				await get_tree().create_timer(randf_range(0.15, 0.25)).timeout
			
			camera.change_mood(false)
			
			_toggle_skill_availability("dark")
			_toggle_skill_availability("light")

		"assassin":
			_toggle_skill_availability("dark")
			
			fx_sprite.play("dark_diffuse")
			ScreenManager.shake_camera(2.0)
			AudioManager.play_sfx("dark_assassin")
			fx_sprite.z_index = 1
			await fx_sprite.animation_finished
			fx_sprite.z_index = 0
			
			$DarkAuraIdle.emitting = true
			
			player_node.base_damage += INSTA_KILL
			player_node.dark_state = true
			
			await get_tree().create_timer(15.0).timeout
			
			$DarkAuraIdle.emitting = false
			
			player_node.base_damage -= INSTA_KILL
			player_node.dark_state = false
			_toggle_skill_availability("dark")
			
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		print("Shockwave hit ", body)
		body.add_debuff("slow")
		body.add_debuff("bleed")
		body.take_damage(10)

func _toggle_skill_availability(type: String) -> void:
	if type == "light":
		can_skill_light = !can_skill_light
	elif type == "dark":
		can_skill_dark = !can_skill_dark
	else:
		printerr("AbilityManager.gd -> No such thing as type ", type)
#func dark_attack() -> void:
#	var vortex_scene := preload("res://scenes/abilities/pulling_matter.tscn")
#	var vortex_instance = vortex_scene.instantiate()
#	energy_manager.empty_values()
#	vortex_instance.global_position = get_viewport_rect().size / 2
#	get_tree().get_root().add_child(vortex_instance)
#	await get_tree().physics_frame
#	vortex_instance.set_vortex(true)
#
#	await get_tree().create_timer(7.0).timeout
#
#	vortex_instance.set_vortex(false)
#
#	await get_tree().create_timer(1.0).timeout
#
#	vortex_instance.queue_free()
