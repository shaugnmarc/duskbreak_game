extends Label
	
func add_value(hurt: bool, value: int, spawn_pos: Vector2) -> void: #
	global_position = spawn_pos - Vector2(0, +12)
	
	show()
	
	if !hurt: # If it's healing!
		modulate = Color("d6ff13")
		text = "+" + str(value)
	else:
		modulate = Color.WHITE
		text = str(value)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", position.y - 12, 1.0)
	tween.tween_property(self, "modulate:a", 0, 2.0)
	
	await tween.step_finished
	
	queue_free()
