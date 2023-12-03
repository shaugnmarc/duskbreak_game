extends Enemy

var is_attacking := false

@onready var timer: Timer = $Timer

var projectile = preload("res://scenes/abilities/slime_projectile.tscn")
var double_attack_start: int = 1

signal spawn_projectile

func _ready() -> void:
	add_to_group("enemy")
	score_give_amount = 20
	energy_give_amount = 15
	
	speed = randf_range(15.0, 30.0)
	
	max_health = 135
	current_health = max_health
	
	timer.wait_time = randf_range(5.0, 6.0)
	
	sprite.play("spawn")
	
	await sprite.animation_finished
	
	sprite.play("walk")
	spawned = true
	
	
	
	if is_instance_valid(vertical_cast):
		vertical_cast.position.x = 10
	
func _process(delta: float) -> void:
	if iframe_cooldown > 0.0:
		iframe_cooldown -= delta
		if iframe_cooldown <= 0.0:
			iframe_cooldown = 0.0
			
func _physics_process(delta: float) -> void:
	if is_attacking:
		return
	
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

func _start_attack() -> void:
	var impulse_strength: float = 130.0
	is_attacking = true
	
	sprite.play("attack")
	
	await spawn_projectile
	
	for i in range(2):  # Create two projectiles
		var projectile_instance = projectile.instantiate()
		projectile_instance.global_position = global_position - Vector2(0, 8)
		get_node("/root/Level").add_child(projectile_instance)
		
		if is_bleeding:
			projectile_instance.reduced_dmg += 10 # Reduces projectile DMG when bleeding

		if i == 0:
			if energy_type == 1:
				projectile_instance.apply_impulse(Vector2.LEFT * impulse_strength)
				
			else:
				projectile_instance.apply_impulse(Vector2.UP * impulse_strength)
			
		else:
			if energy_type == 1:
				projectile_instance.apply_impulse(Vector2.RIGHT * impulse_strength)
			else:
				projectile_instance.apply_impulse(Vector2.DOWN * impulse_strength)
		
		projectile_instance.set_type(energy_type)
		AudioManager.play_sfx("enemy_attack")
	
	await sprite.animation_finished


	sprite.play("walk")
	is_attacking = false

	
	if GameManager.double_atk:
		double_attack_start -= 1
		if double_attack_start >= 0:
			_start_attack()

func _on_timer_timeout() -> void:
	if !is_dead:
		_start_attack()

func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite.frame == 11 and sprite.animation == "attack":
		spawn_projectile.emit()

func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is Player:
		timer.start()

func _on_detect_player_body_exited(body: Node2D) -> void:
	if body is Player:
		timer.stop()
