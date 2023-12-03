extends Node

@onready var sfx: Node = $SFX
@onready var bgm: Node = $BGM

func _ready() -> void:
	AudioServer.set_bus_volume_db(0, -13) # Balances the loudness of every audio emitted

func play_sfx(node: String, vol_db: float = 0.0, pitch: float = 1.0) -> void:
	var target_sfx = load("res://assets/audio/sfx/" + node + ".wav")
	
	if $SFX.has_node(node):
		var sfx_node: AudioStreamPlayer = $SFX.get_node(node)
		sfx_node.stream = target_sfx
		sfx_node.volume_db = vol_db
		sfx_node.pitch_scale = pitch
		sfx_node.play()
	else:
		var sfx_node_instance: AudioStreamPlayer = AudioStreamPlayer.new()
		$SFX.add_child(sfx_node_instance)
		sfx_node_instance.name = node
		
		sfx_node_instance.stream = target_sfx
		sfx_node_instance.volume_db = vol_db
		sfx_node_instance.pitch_scale = pitch
		sfx_node_instance.play()

func play_music(node: String, vol_db: float = 0.0) -> void:
	var target_bgm = load("res://assets/audio/bgm/" + node + ".mp3")

	$BGM/AudioStreamPlayer.stream = target_bgm
	$BGM/AudioStreamPlayer.volume_db = vol_db
	$BGM/AudioStreamPlayer.play()
	
func stop_music() -> void:
	
	if $BGM/AudioStreamPlayer.playing == true:
		$BGM/AudioStreamPlayer.stop()
