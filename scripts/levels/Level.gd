extends Node2D
class_name Level

var level_ended := false
var initial_area: TileMap
var existing_areas: Array = []
var area_scene := preload("res://scenes/levels/middle_map_area.tscn")
var drag_speed: float
var drag_speed_scale: float
var local_speed_scale: float = 250.0

var proceed_area_position: Vector2 = Vector2(0, 0)
var front_area_size: Vector2
var score_interval: float

@onready var camera: Camera2D = %Camera2D
@onready var remove_delay: Timer = $DelayRemove
@onready var hud: CanvasLayer = $Screen
@onready var score_timer: Timer = $ScoreTimer

signal level_start
signal level_end

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.connect_game(self)
	AudioManager.play_music("battle", -8.0)
	
	initial_area = get_node_or_null("InitialMapArea")
	
	if is_instance_valid(initial_area):
		front_area_size = initial_area.get_used_rect().size * 16
		existing_areas.append(initial_area)
		add_area()
		print(initial_area.get_used_rect().size * 16)
	
	await get_tree().create_timer(2.0).timeout
	
	level_start.emit()
	score_timer.start(score_interval)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	score_interval = camera.drag_speed / camera.drag_speed_scale

func add_area() -> void:
	var instance_amount: int = 1
	for i in range(instance_amount):
		var new_area = area_scene.instantiate()
		new_area.global_position.y = -(front_area_size.y - 16) + proceed_area_position.y
		call_deferred("add_child", new_area)
		proceed_area_position = new_area.global_position
		existing_areas.append(new_area)

func remove_area(area: TileMap) -> void:
	print("Removing ", area)
	existing_areas.erase(area)
	area.queue_free()

func _on_marker_snap_update(_i: float) -> void:
	pass

func _on_child_order_changed() -> void:
	for child_index in range(get_child_count()):
		var child = get_child(child_index)
		if child.has_signal("give_score"):
			if !child.is_connected("give_score", _on_enemy_give_score):
				child.give_score.connect(_on_enemy_give_score)

func _on_enemy_give_score(value: int) -> void:
	ScoreManager.add_score(value)

func end_level(death: bool) -> void:
	if death:
		Scenes.to_scene("res://scenes/ui/end_screen.tscn")
		level_end.emit()
	else:
		pass

	score_timer.stop()

func _on_score_timer_timeout() -> void:
	score_timer.start(score_interval)
	ScoreManager.add_score(1)

func force_kill() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy.artificial_death()
