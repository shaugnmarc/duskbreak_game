extends GPUParticles2D

const VORTEX_FORCE := 85.0
const RETURN_FORCE := 100.0  # Adjust the force as needed

var damage_percent := 15 # %

@onready var area := $Area2D

var loop: bool = false

func _ready():
	set_vortex(false)

func set_vortex(start: bool) -> void:
	loop = start
	emitting = start
	area.get_node("CollisionShape2D").disabled = !start

func _physics_process(delta: float) -> void:
	for body in area.get_overlapping_bodies():
		if body is Enemy:
			body.pull_to_center(global_position, loop, body.MAX_HEALTH * damage_percent / 100)
			if loop:
				body.gravity = 0
			else:
				body.gravity = 980
			

#func apply_vortex_force(enemy: CharacterBody2D) -> void:
#	var direction = global_position - enemy.global_position
#	var distance = direction.length()
#
#	if distance > 200:  # Define the threshold distance
#		var return_force = direction.normalized() * RETURN_FORCE
#		enemy.velocity += return_force
#		return
#
#	var force = direction.normalized() * VORTEX_FORCE
#	enemy.velocity += force
#	enemy.take_damage(15, 0, global_position)
