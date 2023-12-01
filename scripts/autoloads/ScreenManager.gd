extends Node

var damage_number_scene = preload("res://scenes/misc/damage_number.tscn")
var hit_mark_scene = preload("res://scenes/vfx/hit_mark.tscn")
var point_hand_cursor = preload("res://assets/ui/mouse_cursor_point.png")
var screen_camera: Camera2D
var hud: CanvasLayer

func _ready() -> void:
	Input.set_custom_mouse_cursor(point_hand_cursor,Input.CURSOR_POINTING_HAND)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	
func shake_camera(intensity: float) -> void:
	if is_instance_valid(screen_camera):
		screen_camera.shake(intensity)
		
func add_indicator(hurt: bool, value: int, spawn_pos: Vector2) -> void:
	var damage_number_instance = damage_number_scene.instantiate()
	get_tree().get_root().add_child(damage_number_instance)
	damage_number_instance.add_value(hurt, value, spawn_pos)
	
	if hurt:
		var hit_mark_instance = hit_mark_scene.instantiate()
		hit_mark_instance.global_position = Vector2(spawn_pos.x, spawn_pos.y - 5)
		get_tree().get_root().add_child(hit_mark_instance)
		hit_mark_instance.play("hit")
		await hit_mark_instance.animation_finished
		hit_mark_instance.queue_free()
	
	
