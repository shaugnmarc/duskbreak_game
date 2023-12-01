extends Camera2D

var shake_strength: float = 0.0
var is_shaking := false

var drag_speed: float = 5.0 # Base speed for upwards movement of camera
var drag_speed_scale: float = 1.0

var score_interval: float = drag_speed / drag_speed_scale
var ongoing_level: bool = false

@onready var level: Level = get_parent()
@onready var orig_offset := offset
@onready var shake_timer: Timer = $ShakeTimer

func _ready() -> void:
	ScreenManager.screen_camera = self

func _process(delta: float) -> void:
	if drag_speed_scale < 2.5: # Camera speed scale cap
		drag_speed_scale += 0.01 * delta
	
	if GameManager.ongoing_game:
		position.y -= drag_speed * drag_speed_scale * delta
	
	# Shaking logic
	if is_shaking:
		offset = Vector2(randf_range(-1, 1) * shake_strength, randf_range(-1, 1) * shake_strength)
		

func shake(intensity: float, length: float = 0.3) -> void:
	if is_shaking or !shake_timer.is_stopped():
		is_shaking = false
		shake_timer.stop()
	
	shake_timer.wait_time = length
	shake_timer.start()
	shake_strength = intensity
	is_shaking = true

func _on_shake_timer_timeout() -> void:
	is_shaking = false
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "offset", orig_offset, 0.1)

func change_mood(start: bool) -> void:
	var tween: Tween = get_tree().create_tween()
	if start:
		tween.tween_property($Mood, "position:y", $Mood.position.y - 185, 0.3)
	else:
		tween.tween_property($Mood, "position:y", $Mood.position.y + 185, 0.3)

func _on_area_2d_body_exited(body: Node2D) -> void: # If player exit camera bounds, take damage
	if body is Player:
		_player_out_bounds(true, body)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_out_bounds(false, body)

func _player_out_bounds(is_outside: bool, node: Player) -> void:
	var health: Node2D = node.get_node("HealthManager")

	health.is_out_bounds = is_outside
