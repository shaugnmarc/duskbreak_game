extends Control



func _on_resume_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().paused = false
	$CenterContainer.hide()
	

func _on_home_pressed() -> void:
	AudioManager.play_sfx("button")
	$ConfirmCenterContainer.show()
	$CenterContainer.hide()


func _on_yes_pressed() -> void:
	GameManager.level.level_end.emit()
	AudioManager.play_sfx("button")
	get_tree().paused = false
	Scenes.to_scene("res://scenes/ui/end_screen.tscn")


func _on_no_pressed() -> void:
	AudioManager.play_sfx("button")
	$ConfirmCenterContainer.hide()
	$CenterContainer.show()
