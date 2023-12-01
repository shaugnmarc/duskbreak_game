extends Node2D

@onready var player: Player = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func heal(amount: int = 15) -> void:
	var health: Node2D = player.get_node("HealthManager")
	health.heal(amount)
	
func power(amount: int = 10) -> void:
	player.base_damage += amount
	await get_tree().create_timer(5.0).timeout
	player.base_damage -= amount
	
