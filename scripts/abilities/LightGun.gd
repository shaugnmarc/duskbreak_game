extends Sprite2D

@onready var player_node: Player = get_parent().get_parent()

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if player_node.get_node("AnimatedSprite2D").flip_h:
		flip_v = true
	else:
		flip_v = false
