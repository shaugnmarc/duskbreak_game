extends Node

const SAVE_PATH: String = "user://user_data.save"

var is_registered := false
var is_logged_in := false
var user_name: String = ""

signal finished_load
signal new_user_register

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_wipe"):
		_wipe_data()
		
func _ready() -> void:
	load_user_data()
	print("LOGGED IN? ",is_logged_in)
	
	await finished_load


func send_user_data(id_name: String, registered: bool, loggedin: bool):
	user_name = id_name
	is_registered = registered
	is_logged_in = loggedin
	
	await get_tree().process_frame
	
	_store_auth_file()
	new_user_register.emit()
	
func load_user_data():
	_load_auth_file()

func _store_auth_file() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var auth_data := {"is_registered" = is_registered, "is_logged_in" = is_logged_in,
	"user_name" = user_name}
	var jstr = JSON.stringify(auth_data)
	save_file.store_line(jstr)
	
	print_rich("[color=green][b]Succesfully saved the following data: [/b][/color]", auth_data)
	
	save_file.close()

func _load_auth_file() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = save_file.get_as_text()
		
		if !save_file.eof_reached():
			var current_line = JSON.parse_string(save_file.get_line())
			
			if current_line:
				is_registered = current_line["is_registered"]
				is_logged_in = current_line["is_logged_in"]
				user_name = current_line["user_name"]
				
				await get_tree().process_frame
				
				finished_load.emit()
				
				print_rich("[color=green][b]Succesfully loaded the following data: [/b][/color]", current_line)
		
		save_file.close()
	
	else:
		print(SAVE_PATH, " file not found.")

func _wipe_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print_rich("[color=blue][b]Succesfully wiped user data.[/b][/color]")
		is_logged_in = false
		is_registered = false
		user_name = ""
	else:
		print(SAVE_PATH, " has not been created yet. Reloading")

	if FileAccess.file_exists(ScoreManager.SAVE_PATH):
		DirAccess.remove_absolute(ScoreManager.SAVE_PATH)
		print_rich("[color=blue][b]Succesfully wiped score data.[/b][/color]")
	else:
		print(ScoreManager.SAVE_PATH, " has not been created yet. Reloading")

	await get_tree().create_timer(1.0).timeout
		
	get_tree().reload_current_scene()
