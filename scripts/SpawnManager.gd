extends Node2D

var slime_big = preload("res://scenes/characters/slime_big.tscn")
var slime_darkbig = preload("res://scenes/characters/slime_darkbig.tscn")
var slime = preload("res://scenes/characters/slime.tscn")
var slime_dark = preload("res://scenes/characters/slime_dark.tscn")

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
	
	
	# 30% chance for spawning a small slimes, 70% for a big slime
	if size_chance <= 3:
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
		
		if spawn_chance <= 5: # 50% chance of a big slime spawning with a small slime
			slime_instance.global_position = Vector2(randi_range(80, 230), at_pos)
			get_parent().add_child(slime_instance)

func _on_start_delay_timeout() -> void:
	snap_enable = true
