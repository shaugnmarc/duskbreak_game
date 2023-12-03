extends CharacterBody2D
class_name Player

const BASE_SPEED := 80.0
const JUMP_VELOCITY := -300.0
const DOWN_SPEED := 1.0 

@onready var collision_shape := $BodyCollision
@onready var sprite := $AnimatedSprite2D
@onready var collision_attack := $AttackArea/AttackCollision
@onready var orig_collision_attack_pos: float = collision_attack.position.x
@onready var orig_atk_spd: float = sprite.speed_scale

@export var base_damage: int = 35

var current_speed := BASE_SPEED
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dropping := false
var is_attacking := false
var is_beaming := false
var flip_based_on_mouse := false
var attack_timer: Timer
var attack_speed: float = 1.0: # 1 is normal speed
	set(_new_value):
		if _new_value > 5.0:
			attack_speed = 5.0
		else:
			attack_speed = _new_value
# Determines which part of the attack pattern will be executed
var attack_index: int = 0

# STATES
var light_state := false
var dark_state := false
var direction: int = 1

# COMPONENTS
@onready var health := $HealthManager

const ATTACK_ANIMATIONS := ["attack_0", "attack_1", "attack_2"]

func _ready():
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	add_child(attack_timer)
	attack_timer.connect("timeout", _reset_attack)
	

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !is_attacking:
		jump()

	if Input.is_action_just_pressed("ui_up") and is_on_floor() and !is_attacking:
		jump()

	if Input.is_action_just_pressed("ui_down") and is_on_floor() and !is_dropping and !is_attacking:
		move_down()

	if Input.is_action_just_pressed("fire") and is_on_floor() and !is_attacking:
		_handle_attack_chain()

	if Input.is_action_just_pressed("dir_click"):
		_change_dir()

	if Input.is_action_just_pressed("ui_right"):
		direction = 1

	if Input.is_action_just_pressed("ui_left"):
		direction = -1
	
	if !is_attacking:
		if direction > 0:
			velocity.x = current_speed
			flip_body(false)
			sprite.play("run")
		elif direction < 0:
			velocity.x = -current_speed
			flip_body(true)
			sprite.play("run")
		else:
			velocity.x = 0
			sprite.play("idle")
	
	if flip_based_on_mouse:
		_flip_body_based_on_mouse()
	
	move_and_slide()

func jump() -> void:
	velocity.y = JUMP_VELOCITY
	AudioManager.play_sfx("player_vertical", -6.0)

func _change_dir() -> void:

	var mouse_pos: Vector2 = get_local_mouse_position()
	var horizontal_threshold: float = 15  # Adjust this value for your desired x-range

	if mouse_pos.x < -horizontal_threshold:
		flip_body(true)
		direction = -1
	elif mouse_pos.x > horizontal_threshold:
		flip_body(false)
		direction = 1

#	if is_attacking: # Don't let player jump/move down while attacking
#		return
#
#	var jump_threshold: float = -40.0 
#	var move_down_threshold: float = 10.0
#
#	if mouse_pos.y < jump_threshold and is_on_floor():
#		jump()
#	elif mouse_pos.y > move_down_threshold and is_on_floor():
#		move_down()

func move_down() -> void:
	AudioManager.play_sfx("player_vertical", -8.0)
	is_dropping = true
	set_collision_mask_value(1, false)
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(1, true)
	is_dropping = false

func flip_body(flip: bool) -> void:
	if !flip:
		sprite.flip_h = false
		collision_attack.position.x = orig_collision_attack_pos
	else:
		sprite.flip_h = true
		collision_attack.position.x = -orig_collision_attack_pos

func _flip_body_based_on_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var is_mouse_on_left = mouse_pos.x < global_position.x
	flip_body(is_mouse_on_left)
	
func increase_stat(amount: float) -> void:
	attack_speed += amount

func _handle_attack_chain() -> void:
	if is_beaming:
		return

	var tween := get_tree().create_tween()
	var attack_force := 6.0 # How strong is the attack pull
	
	
	is_attacking = true
	_change_dir()
	collision_attack.disabled = true
	collision_attack.scale = Vector2(0.2,.2)
	tween.set_trans(Tween.TRANS_EXPO)
	AudioManager.play_sfx("player_slash", -5.5, 3.0 - attack_index)
	
	if get_local_mouse_position().x < 0:
		flip_body(true)
		tween.tween_property(self, "global_position:x", global_position.x - attack_force, 0.1)
	elif get_local_mouse_position().x > 0:
		flip_body(false)
		tween.tween_property(self, "global_position:x", global_position.x + attack_force, 0.1)
	
	velocity = Vector2.ZERO
	sprite.speed_scale = attack_speed
	print(attack_speed)

	sprite.play(ATTACK_ANIMATIONS[attack_index])
	attack_timer.start(1.0)  # Start the timer for the attack sequence reset

	attack_index += 1
	
	if attack_index >= ATTACK_ANIMATIONS.size():
		attack_index = 0

	await sprite.animation_finished
	
	sprite.speed_scale = 1.0
	is_attacking = false
	collision_attack.disabled = true
	collision_attack.scale = Vector2(0.2,0.2)

func _reset_attack() -> void:
	attack_index = 0
	

func _on_animated_sprite_2d_frame_changed() -> void:
	# Enables the attack collision only when the attack trail shows up
	if sprite.frame == 2 and is_attacking:
		collision_attack.scale = Vector2(1,1)
		collision_attack.disabled = false
		if sprite.animation == "attack_2":
			collision_attack.scale.x = collision_attack.scale.x + 0.5
			var tween = get_tree().create_tween()
			if sprite.flip_h:
				tween.tween_property(collision_attack, "position:x", -54, 0.4)
			else:
				tween.tween_property(collision_attack, "position:x", 54, 0.4)
			await tween.step_finished
			collision_attack.scale = Vector2(0.2,0.2)
			

func _process(delta: float) -> void:
	pass

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if body.has_method("take_damage"):
	# Not all attack strings have the same damage output or knockback strength
			match attack_index: 
				0:
					body.take_damage(base_damage + 3, 0, global_position)
				1:
					body.take_damage(base_damage + 1, 0, global_position)
				2:
					body.take_damage(base_damage + 2, 0, global_position)
					
			
			if dark_state: # If the player has activated the ASSASSIN skill
				var tween: Tween = get_tree().create_tween()
				sprite.modulate = Color("331c54")
				tween.tween_property(sprite, "modulate", Color.WHITE, 0.75)
				
				health.take_damage(7)
				
			elif light_state:
				pass

