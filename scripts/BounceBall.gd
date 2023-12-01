extends CharacterBody2D

var dir := Vector2(90, 90) # Initial speed in pixels per second

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(dir * delta)
	if collision:
		dir = dir.bounce(collision.get_normal())

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(100, 0, global_position)
