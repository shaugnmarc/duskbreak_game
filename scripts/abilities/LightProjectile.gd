extends RigidBody2D

@export var speed: int = 125
@export var max_distance: int = 1000
@export var max_hits: int = 3

@onready var player_node: Player = get_parent().get_node_or_null("Player")

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	
	$Area2D/CollisionShape2D.disabled = true
	await get_tree().physics_frame
	$Area2D/CollisionShape2D.disabled = false

func set_speed(new_speed: int) -> void:
	speed = new_speed
	
func shoot_at_mouse(start_pos: Vector2) -> void:
	global_position = start_pos
	var direction = (get_global_mouse_position() - start_pos).normalized()
	linear_velocity = direction * speed

func _physics_process(delta: float) -> void:
	var current_distance := global_position.distance_to(get_global_mouse_position())
	if current_distance > max_distance:
		queue_free()

func shoot_in_direction(target_direction: Vector2) -> void:
	var direction := target_direction.normalized()
	linear_velocity = direction * speed
	var rotation_angle = atan2(direction.y, direction.x)
	rotation_degrees = rad_to_deg(rotation_angle)

func fade() -> void:
	sleeping = true
	$AnimatedSprite2D.play("fade")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(body.max_health / 1.42)
		
		if is_instance_valid(player_node):
			player_node.get_node("HealthManager").heal(10)

		max_hits -= 1
		if max_hits < 1:
			fade()
	else:
		fade()
