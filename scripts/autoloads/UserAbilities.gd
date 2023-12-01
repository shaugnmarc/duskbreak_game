extends Node

var chosen_light: String
var chosen_dark: String

signal abilities_changed

func select_light(ability: String) -> void:
	chosen_light = ability
	abilities_changed.emit()
	
func select_dark(ability: String) -> void:
	chosen_dark = ability
	abilities_changed.emit()

func reset_all() -> void:
	chosen_dark = ""
	chosen_light = ""
