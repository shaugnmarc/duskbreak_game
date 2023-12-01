extends RayCast2D

@onready var line := $Line2D
@onready var cast_particles := $CastingParticles
@onready var collision_particles := $CollisionParticles
@onready var beam_particles := $BeamParticles
@onready var line_width: float = line.width
@onready var light := $DirectionalLight2D

var cast_speed := 700.0
var max_length := 1400.0
var growth_time := 0.1
var is_casting := false
var base_damage := 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)
	line.points[1] = Vector2.ZERO
	line.width = 0

func _physics_process(delta: float) -> void:
	target_position = (target_position + Vector2.RIGHT * cast_speed * delta).limit_length(max_length)
	
	rotation = lerp_angle(rotation, rotation + get_angle_to(get_global_mouse_position()), 0.1) 
	
	cast_beam()

	if is_colliding():
		var body = get_collider()
		if body is Enemy and body.is_in_group("enemy"):
			if body.has_method("take_damage") and is_instance_valid(body):
				body.take_damage(base_damage, 0, global_position)

func toggle_laser(cast: bool) -> void:
	is_casting = cast
	
	if is_casting:
		target_position = Vector2.ZERO
		line.points[1] = target_position
		appear()
	else:
		# Reset the laser endpoint
		line.points[1] = Vector2.ZERO
		
		collision_particles.emitting = false
		disappear()

	set_physics_process(is_casting)
	beam_particles.emitting = is_casting
	
	light.enabled = is_casting
	cast_particles.emitting = is_casting
	$SoundTimer.paused = !is_casting

func appear() -> void:
	var tween := get_tree().create_tween()

	tween.tween_property(line, "width", line_width, growth_time * 2)

func disappear() -> void:
	var tween := get_tree().create_tween()

	tween.tween_property(line, "width", 0, growth_time)

func cast_beam() -> void:
	ScreenManager.shake_camera(1.0)
	var cast_point := target_position

	force_raycast_update()
	collision_particles.emitting = is_colliding()

	if is_colliding():
		cast_point = to_local(get_collision_point())
		collision_particles.global_rotation = get_collision_normal().angle()
		collision_particles.position = cast_point

	line.points[1] = cast_point
	beam_particles.position = cast_point * 0.5
	beam_particles.process_material.emission_box_extents.x = cast_point.length() * 0.5

func _on_sound_timer_timeout() -> void:
	AudioManager.play_sfx("light_laser_beam", -10.0, 4.0)
