extends TileMap

enum AreaType {
	INITIAL,
	MIDDLE
}

@export var area_type: AreaType = AreaType.INITIAL

var first_floor_y: float = 180.0
var second_floor_y: float = 132.0
var third_floor_y: float = 82.0
var fourth_floor_y: float = 36.0

var slime_big = preload("res://scenes/characters/slime_big.tscn")
var slime = preload("res://scenes/characters/slime.tscn")

func _ready() -> void:
	$Delay.timeout.connect(spawn_slimes)

	if GameManager.varied_platforms:
		_alter_platforms()
	
func _alter_platforms() -> void:
	var tiles_to_remove: int = 6
	var removed_count: int = 0
	var removed_y_coords: Array = []  # Store removed x-coordinates

	while removed_count < tiles_to_remove:
		var x = randi_range(4, 14)  # Random x-coordinate between 4 and 14 (to ensure adjacent pairs)
		var y = randi_range(3, 12)  # Random y-coordinate between 3 and 12

		if !removed_y_coords.has(y):
			var tile = get_cell_source_id(1, Vector2i(x, y))
			var next_tile = get_cell_source_id(1, Vector2i(x + 1, y))  # Check next tile in x-axis

			if tile != -1 and next_tile != -1:
				print("Removing tiles at: ", x, ", ", y)
				set_cell(1, Vector2i(x, y), -1)  # Remove current tile
				set_cell(1, Vector2i(x + 1, y), -1)  # Remove adjacent tile
				removed_count += 2  
				removed_y_coords.append(y) 


func spawn_slimes() -> void:
	var floors = [first_floor_y, second_floor_y, third_floor_y]
	var used_floors = []

	for flr in floors:
		for i in range(1):  # Spawn x small slime on each used floor
			spawn_small_slime(flr)
			
	for i in range(2):  # Spawn x big slimes
		var rand_floor = floors[randi() % floors.size()]
		floors.erase(rand_floor)
		used_floors.append(rand_floor)
		spawn_big_slime(rand_floor)

func spawn_big_slime(floor_y: float) -> void:
	var slime_instance = slime_big.instantiate()
	var x = randf_range(76, 240)
	slime_instance.global_position = Vector2(x, floor_y)
	add_child(slime_instance)

func spawn_small_slime(floor_y: float) -> void:
	var slime_instance = slime.instantiate()
	var x = randf_range(76, 240)

	if floor_y == first_floor_y:
		x = randf_range(76, 140)
	else:
		x = randf_range(140, 240)

	slime_instance.global_position = Vector2(x, floor_y)
	add_child(slime_instance)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("camera"):
		print("MapArea.gd -> Has been detected, adding new area above ", self.name)
		get_parent().add_area()

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("camera"):
		print("MapArea.gd -> Deleting ", self)
		get_parent().remove_area(self)
