extends RigidBody2D

var reduced_dmg: int = 0

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	$Lifetime.start()
	$Area2D/CollisionShape2D.disabled = true
	
	await get_tree().create_timer(0.25).timeout
	
	$Area2D/CollisionShape2D.disabled = false

func _fade() -> void:
	sleeping = true # Stops the projectile
	$AnimatedSprite2D.play("die")
	
	await $AnimatedSprite2D.animation_finished
	
	queue_free()
	
func set_type(type: int) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.get_node("HealthManager").take_damage(GameManager.base_damage["slime_projectile"] - reduced_dmg)
		_fade()

func _on_lifetime_timeout() -> void:
	_fade()
