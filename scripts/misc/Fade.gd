extends CanvasLayer

signal anim_finished
	
func start_anim() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Fade, "position:y", $Fade.position.y + 190, 0.3)
	await tween.step_finished
	anim_finished.emit()
	
func reverse_anim() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Fade, "position:y", $Fade.position.y - 190, 0.3)
	await tween.step_finished
	anim_finished.emit()
