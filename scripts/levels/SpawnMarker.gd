extends Node2D
class_name Marker

var grid_size: int = 48
var initial_offset: Vector2
var prev_snap: float = 0
var snap_enabled := false

signal snap_update

@onready var area := $Area2D
@onready var camera := %Camera2D

func _ready() -> void:
	# Store the initial offset from the camera's top-left offset position
	initial_offset = global_position - camera.global_position
	
	%StartDelay.timeout.connect(_on_delay_timeout)
	%StartDelay.start()

func _physics_process(delta: float) -> void:
	if snap_enabled:
		var camera_pos: Vector2 = camera.global_position
		
		var snapped_pos: float = snappedf(initial_offset.y + camera_pos.y, grid_size) - 1 # Margin of error
		
		# Emit signal if the position changes
		if snapped_pos != prev_snap:
			prev_snap = snapped_pos
			snap_update.emit(snapped_pos)
		
		# Apply the snapped position to the node's y-coordinate
		area.global_position.y = snapped_pos

func _on_delay_timeout() -> void:
	snap_enabled = true
