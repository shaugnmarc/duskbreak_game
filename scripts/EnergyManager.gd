extends Node2D
class_name PlayerEnergy

const MAX_ENERGY: int = 100

var light_energy: int = 50:
	set(_new_value): # Clamping
		if _new_value <= 0:
			light_energy = 0
			light_maxed = false
		elif _new_value >= 100:
			light_energy = 100
			light_maxed = true
		else:
			light_energy = _new_value
			light_maxed = false

var dark_energy: int = 50:
	set(_new_value): # Clamping
		if _new_value <= 0:
			dark_energy = 0
			dark_maxed = false
		elif _new_value >= 100:
			dark_energy = 100
			dark_maxed = true
		else:
			dark_energy = _new_value
			dark_maxed = false

var light_maxed := false
var dark_maxed := false

@onready var ability_manager := %AbilityManager

func _ready() -> void:
	# DEBUG PURPOSES, REMOVE IN FINAL BUILD
	add_dark_energy(100)
	add_light_energy(100)
	pass

func _process(delta: float) -> void:
	pass

func add_light_energy(value: int) -> void:
	light_energy += value
	#dark_energy = MAX_ENERGY - light_energy

func add_dark_energy(value: int) -> void:
	dark_energy += value
	#light_energy = MAX_ENERGY - dark_energy

func empty_value(type: String) -> void:
	if type == "dark":
		dark_energy = 0
	elif type == "light":
		light_energy = 0
	else:
		print("EnergyManager.gd -> There is no such thing as type", type)

