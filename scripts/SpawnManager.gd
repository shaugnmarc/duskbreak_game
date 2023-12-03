extends Node2D

const slime_big = preload("res://scenes/characters/slime_big.tscn")
const slime_darkbig = preload("res://scenes/characters/slime_darkbig.tscn")
const slime = preload("res://scenes/characters/slime.tscn")
const slime_dark = preload("res://scenes/characters/slime_dark.tscn")

var snap_enable := false

func _ready() -> void:
	for marker in get_children():
		if marker is Marker:
			marker.snap_update.connect(_spawn_enemy)
			
	$StartDelay.start()

func _spawn_enemy(at_pos: float = 0) -> void:
	# Generate a random number between 1 and 10
	var size_chance := randi_range(0, 10)
	var slime_instance = slime.instantiate()
	
	# 70% chance for spawning a small slimes, 30% for a big slime
	if size_chance <= 7:
		var small_slime_amount: int = 1
		for i in range(small_slime_amount): # Spawns x small slime/s
			var type_chance := randi_range(0, 10)
			if small_slime_amount > 1:
				if i == 0:
					slime_instance = slime.instantiate()  # Light slime
				else:
					slime_instance = slime_dark.instantiate()  # Dark slime
			else:
				if type_chance <= 5:
					slime_instance = slime.instantiate() 
				else:
					slime_instance = slime_dark.instantiate()

			slime_instance.global_position = Vector2(randi_range(80, 230), at_pos)
			get_parent().add_child(slime_instance)

	else:
		var type_chance := randi_range(0, 10)
		var spawn_chance := randi_range(0, 10)
		# 50% chance for spawning a dark slime, 50% for a light slime
		if type_chance <= 5: 
			var slime_big_instance = slime_big.instantiate()
			slime_big_instance.global_position = Vector2(randi_range(80, 230), at_pos)
			get_parent().add_child(slime_big_instance)
			
			slime_instance = slime.instantiate()
		else:
			var slime_darkbig_instance = slime_darkbig.instantiate()
			slime_darkbig_instance.global_position = Vector2(randi_range(80, 230), at_pos)
			get_parent().add_child(slime_darkbig_instance)
			
			slime_instance = slime_dark.instantiate()
		
		if spawn_chance <= 7: # 70% chance of a big slime with another big slime
			if type_chance <= 5: 
				var slime_big_instance = slime_big.instantiate()
				slime_big_instance.global_position = Vector2(randi_range(80, 230), at_pos)
				get_parent().add_child(slime_big_instance)
				
				slime_instance = slime.instantiate()
			else:
				var slime_darkbig_instance = slime_darkbig.instantiate()
				slime_darkbig_instance.global_position = Vector2(randi_range(80, 230), at_pos)
				get_parent().add_child(slime_darkbig_instance)
				
				slime_instance = slime_dark.instantiate()

func _on_start_delay_timeout() -> void:
	snap_enable = true
