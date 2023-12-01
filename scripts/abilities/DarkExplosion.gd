extends AnimatedSprite2D

@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	play("explode")
	
	await animation_finished
	
	queue_free()

func _process(delta: float) -> void:
	if frame == 5 and !collision.disabled:
		collision.disabled = true
		ScreenManager.shake_camera(3.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(100)
