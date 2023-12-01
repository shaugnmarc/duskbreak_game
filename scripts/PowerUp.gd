extends RigidBody2D

var can_pickup := false

enum POWER_UP {NONE, HEALTH, GOLDHEALTH}

var type: POWER_UP = POWER_UP.NONE

func _ready() -> void:
	$AnimatedSprite2D.play("spawn")
	await $AnimatedSprite2D.animation_finished
	
	var rand_chance: int = randi_range(0, 10)
	if rand_chance <= 8: # 80% CHANCE to spawn regular health packs
		type = POWER_UP.HEALTH
		$AnimatedSprite2D.play("health")
	else:
		type = POWER_UP.GOLDHEALTH
		$AnimatedSprite2D.play("goldhealth")
	
	can_pickup = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _fade() -> void:
	$AnimatedSprite2D.play("pickup")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if can_pickup:
			var stat_node: Node2D = body.get_node("Boosts")
			match type:
				POWER_UP.HEALTH:
					stat_node.heal(12)
				POWER_UP.GOLDHEALTH:
					stat_node.heal(20)
			_fade()

func _on_lifetime_timeout() -> void:
	_fade()
