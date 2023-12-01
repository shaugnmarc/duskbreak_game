extends Node

@onready var sfx: Node = $SFX
@onready var bgm: Node = $BGM

func _ready() -> void:
	pass

func play_sfx(node: String, vol_db: float = 0.0, pitch: float = 1.0) -> void:
	var target_sfx = load("res://assets/audio/sfx/" + node + ".wav")
	
	$SFX/AudioStreamPlayer2D.stream = target_sfx
	$SFX/AudioStreamPlayer2D.volume_db = vol_db
	$SFX/AudioStreamPlayer2D.pitch_scale = pitch
	$SFX/AudioStreamPlayer2D.play()

func play_music(node: String, vol_db: float = 0.0) -> void:
	var target_bgm = load("res://assets/audio/bgm/" + node + ".mp3")

	$BGM/AudioStreamPlayer2D.stream = target_bgm
	$BGM/AudioStreamPlayer2D.volume_db = vol_db
	$BGM/AudioStreamPlayer2D.play()
