extends Node2D

@export var max_health: int = 100
@export var current_health: int:
	set(_new_value):
		if _new_value > max_health:
			current_health = max_health
		elif _new_value < 0:
			current_health = 0
			player_die()
		else:
			current_health = _new_value

@onready var player: Player = get_parent()
@onready var timer: Timer = $HurtTimer

var is_out_bounds: bool:
	# Logic for hurting the player for being outside the screen
	set(_new_bool):
		if _new_bool:
			timer.start()
		else:
			timer.stop() 

func _ready() -> void:
	current_health = max_health
	
func _process(delta: float) -> void:
	pass

func _on_hurt_timer_timeout() -> void:
	take_damage(10)

func player_die() -> void:
	get_node("/root/Level").end_level(true)

func take_damage(amount: int) -> void:
	AudioManager.play_sfx("player_hit")
	
	%AnimationPlayer.play("blink")
	
	current_health -= amount
	
	ScreenManager.shake_camera(2.0)
	ScreenManager.add_indicator(true, amount, global_position)
		
func heal(amount: int) -> void:
	if !is_instance_valid(player):
		return
	
	AudioManager.play_sfx("player_heal", -8.0)
	current_health += amount
	ScreenManager.add_indicator(false, amount, global_position)
	
	player.get_node("AnimatedSprite2D").self_modulate = Color("bef367")
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(player.get_node("AnimatedSprite2D"), "self_modulate", Color.WHITE, 0.75)


