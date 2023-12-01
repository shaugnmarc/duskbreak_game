extends Control

@onready var shockwave_anim := $Shockwave/AnimationPlayer
@onready var player_node: Player = get_parent().get_parent().get_node_or_null("Player") 

func _ready() -> void:
	$Shockwave.hide()

func start_shockwave(at_pos: Vector2) -> void:
	$Shockwave.show()
	$Shockwave.material.set_shader_parameter("center", at_pos)
	shockwave_anim.play("shockwave")
	
#	var screen_camera: Camera2D = ScreenManager.screen_camera
#	if is_instance_valid(screen_camera):
#
#		var tween: Tween = get_tree().create_tween()
#		tween.tween_property(screen_camera, "zoom", Vector2(0.9, 0.9), 1.5)
	
	await shockwave_anim.animation_finished

#	if is_instance_valid(screen_camera):
#
#		var tween: Tween = get_tree().create_tween()
#		tween.tween_property(screen_camera, "zoom", Vector2(1, 1), 1.5)

	$Shockwave.hide()


