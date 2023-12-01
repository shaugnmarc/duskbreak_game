extends Node

var fade_scene = preload("res://scenes/ui/fade.tscn")
func to_scene(path: String) -> void:
	
	var fade_node: CanvasLayer = fade_scene.instantiate()
	get_tree().get_root().add_child(fade_node)
	
	fade_node.start_anim()
	await fade_node.anim_finished
	
	get_tree().change_scene_to_file(path)
	
	await get_tree().create_timer(1.0).timeout
	fade_node.reverse_anim()
	await fade_node.anim_finished
	
	fade_node.queue_free()
