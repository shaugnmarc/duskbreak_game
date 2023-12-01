extends Control

var fade_scene = preload("res://scenes/ui/fade.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UserAbilities.chosen_dark = ""
	UserAbilities.chosen_light = ""
	ScoreManager.reset_current_score()
	GameManager.reset_run_progress()
	
	$Elements.modulate.a = 0
	
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($Elements, "modulate:a", 1, 2.0)
	
	await get_tree().create_timer(1.0)
	
	_animate_menu_knight($Sprites/KnightMenuSprite)
	
	AudioManager.play_music("menu")
	
func _animate_menu_knight(sprite: AnimatedSprite2D) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(sprite, "global_position:x", 105, 2.5)
	sprite.play("walk")
	await tween.step_finished
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/select_menu.tscn")
	AudioManager.play_sfx("button_start")

func _on_title_mouse_entered() -> void:
	$Elements/Title.position.y -= 3.5

func _on_title_mouse_exited() -> void:
	$Elements/Title.position.y += 3.5
