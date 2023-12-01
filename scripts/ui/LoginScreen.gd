extends Control

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")


func _ready():
	SilentWolf.Auth.sw_login_complete.connect(_on_login_complete)
	hide_processing_label()


func _on_login_pressed() -> void:
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Login.disabled = true
	var username = $CenterContainer/ContainerRect/InputFields/UsernameEdit.text
	var password = $CenterContainer/ContainerRect/InputFields/PwEdit.text
	var remember_me: bool = true
	SWLogger.debug("Login form submitted, remember_me: " + str(remember_me))
	SilentWolf.Auth.login_player(username, password, remember_me)
	show_processing_label("Processing...")


func _on_login_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		login_success()
	else:
		login_failure(sw_result.error)


func login_success() -> void:
	show_processing_label("Logged in as: " + str(SilentWolf.Auth.logged_in_player))
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Login.disabled = true
	UserData.send_user_data(str(SilentWolf.Auth.logged_in_player), true, true)

func login_failure(error: String) -> void:
	show_processing_label("Log in failed: " + str(error))
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Login.disabled = false

func show_processing_label(info: String) -> void:
	$CenterContainer/ContainerRect/Message/MessageLabel.text = info
	$CenterContainer/ContainerRect/Message.show()


func hide_processing_label() -> void:
	$CenterContainer/ContainerRect/Message.hide()


func _on_back_home_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/start_menu.tscn")
