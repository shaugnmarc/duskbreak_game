extends CharacterBody2D
class_name Enemy

const ACCELERATION = 300.0
const DECELERATION = 600.0
const IFRAME_DURATION := 0.15

@export_range(0, 1) var energy_type: int = 0 # 0 is light, 1 is dark
@export var energy_give_amount: int = 8 # Amount of energy dropped
@export var score_give_amount: int = 10

@onready var sprite := $AnimatedSprite2D
@onready var collision := $CollisionShape2D
@onready var player_node: Player = get_parent().get_node("Player")

signal give_score

var speed: float = 20.0
var max_health: int = 100
var current_health: int
var dir: int = 1
var power_up = preload("res://scenes/levels/power_up.tscn")
var hit_mark = preload("res://scenes/vfx/hit_mark.tscn")
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var iframe_cooldown: float
var target_velocity_x: float = 0.0
var spawned := false
var lifetime: float = 40.0
var is_dead := false
var orig_modulate := Color.WHITE
var vertical_cast: RayCast2D
var horizontal_cast: RayCast2D
var is_bleeding := false
var facing_right := true

func _ready() -> void:
	
	set_collision_layer_value(9, true)
	
	add_to_group("enemy")
	current_health = max_health
	sprite.play("spawn")
	
	await sprite.animation_finished
	
	spawned = true
	sprite.play("walk")
	
	_remove_from_scene(lifetime)
	

func _physics_process(delta: float) -> void:
	
	
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		if spawned:
			if !$RayCasts/DownRightCast.is_colliding():
				flip()
				
			if $RayCasts/UpRightCast.is_colliding():
				flip()

	target_velocity_x = speed


	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	move_and_slide()
	
func flip() -> void:
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1

func _process(delta: float) -> void:
	if iframe_cooldown > 0.0:
		iframe_cooldown -= delta
		if iframe_cooldown <= 0.0:
			iframe_cooldown = 0.0
			

func initiate_death() -> void:
	var rand_chance: int = randi_range(0, 10)
	is_dead = true
	set_collision_layer_value(2, false)
	
	if is_instance_valid(player_node):
		var player_energy: Node2D = player_node.get_node("EnergyManager")
		
		match energy_type:
			0:
				player_energy.add_light_energy(energy_give_amount)
			1:
				player_energy.add_dark_energy(energy_give_amount)
		
		give_score.emit(score_give_amount)
		player_node.increase_stat(0.001)
		GameManager.add_enemy_kill()
		
	
	if rand_chance <= 1: # 10% chance to spawn a power-up
		var power_up_instance := power_up.instantiate()
		power_up_instance.global_position = global_position
		get_parent().call_deferred("add_child", power_up_instance)
	
	
	sprite.stop()
	sprite.play("die")
	await sprite.animation_finished
	queue_free()

func artificial_death() -> void: # func initiate_death() basically but does not interact with player
	is_dead = true
	set_collision_layer_value(2, false)
	ScreenManager.shake_camera(1.0)
	
	sprite.stop()
	sprite.play("die")
	await sprite.animation_finished
	queue_free()
	
func _remove_from_scene(duration: float) -> void: # Remove no-longer-visible enemy
	await get_tree().create_timer(duration).timeout
	queue_free()

func take_damage(amount: int, knockback_strength: float = 0.0, source_pos: Vector2 = Vector2.ZERO) -> void:
	if iframe_cooldown > 0.0 or is_dead:
		return
	
	iframe_cooldown = IFRAME_DURATION
	current_health -= amount
	
	ScreenManager.shake_camera(1.0)
	ScreenManager.add_indicator(true, amount, global_position)
	AudioManager.play_sfx("enemy_hit")
	#print(damage_amount, " damage absorbed")
	
	if knockback_strength != 0.0:
		var knockback_direction = source_pos.x - global_position.x
		var knockback = knockback_direction * knockback_strength
		var tween = create_tween()
		
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "global_position:x", global_position.x - knockback, 0.2)

	var tween = create_tween()
	sprite.self_modulate = Color.BLACK
	sprite.scale = Vector2(1.2, 1.2)
	tween.tween_property(sprite, "self_modulate", orig_modulate, 0.25)
	tween.tween_property(sprite, "scale", Vector2(1, 1), 0.25)
	
	if current_health <= 0:
		initiate_death()

func add_debuff(type: String) -> void:
	if type == "slow":
		speed = speed * 1/8
	elif type == "bleed":
		start_bleed()
		
func start_bleed(linger_time: float = 10.0) -> void:
	var bleed_timer = Timer.new()
	bleed_timer.wait_time = 2.0
	bleed_timer.timeout.connect(_on_bleed_timer_timeout)
	add_child(bleed_timer)
	bleed_timer.start()
	
	is_bleeding = true
	sprite.self_modulate = Color.MEDIUM_PURPLE
	orig_modulate = Color.MEDIUM_PURPLE
	
	await get_tree().create_timer(linger_time).timeout
	
	is_bleeding = false
	sprite.self_modulate = Color.WHITE
	orig_modulate = Color.WHITE
	
	bleed_timer.stop()
	bleed_timer.queue_free()
	
func _on_bleed_timer_timeout() -> void:
	take_damage(15)

#func pull_to_center(center: Vector2, loop: bool, damage: int = 0) -> void:
#	await get_tree().physics_frame
#	var direction := center - global_position
#	var force := direction.normalized() * 35.0
#	var has_damage := false
#
#	collision.disabled = true
#	velocity += force
#
#	if damage > 0:
#		has_damage = true
#		take_damage(damage)
#
#	if loop: 
#		pull_to_center(center, loop, damage)
#
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		match dir:
			0:
				dir = 1
			1:
				dir = 0
