extends Node

var base_damage := {"slime_projectile": 15}
var ongoing_game := false
var enemy_kills: int = 0

var level: Level
var milestone: Milestone:
	set(_milestone_node):
		milestone = _milestone_node
		milestone.milestone_reached.connect(_on_milestone)
var varied_platforms := false
var double_atk := false

@onready var timer: Timer = Timer.new()
@onready var map_timer: Timer = Timer.new()
@onready var atk_timer: Timer = Timer.new()

signal kill_counter_changed

func _ready() -> void:
	add_child(map_timer)
	add_child(timer)
	add_child(atk_timer)
	
	map_timer.timeout.connect(_on_map_timer_timeout)
	timer.timeout.connect(_strengthen_base_damage)
	atk_timer.timeout.connect(_allow_double_attack)

func _on_milestone(index: int) -> void:
	match index:
		1:
			pass
		2:
			pass
		3:
			pass
		
func connect_game(level_node: Level) -> void:
	level_node.level_start.connect(level_start)
	level_node.level_end.connect(level_end)
	level = level_node
		
func level_start() -> void:
	ongoing_game = true
	
	timer.wait_time = 60.0
	timer.one_shot = false
	timer.start()
	
	map_timer.wait_time = 30.0
	map_timer.one_shot = true
	map_timer.start()
	
	atk_timer.wait_time = 90.0
	atk_timer.one_shot = true
	atk_timer.start()

func _on_map_timer_timeout() -> void:
	varied_platforms = true

func level_end() -> void:
	ongoing_game = false
	timer.stop()
	map_timer.stop()
	atk_timer.stop()
	print("Game ended!")
	
func _allow_double_attack() -> void:
	double_atk = true

func _strengthen_base_damage() -> void:
	base_damage["slime_projectile"] += 1

func add_enemy_kill(amount: int = 1) -> void:
	enemy_kills += amount
	kill_counter_changed.emit(enemy_kills)

func reset_run_progress() -> void:
	ongoing_game = false
	double_atk = false
	varied_platforms = false
	enemy_kills = 0
	base_damage["slime_projectile"] = 15 # Base damage for enemy projectiles
	
