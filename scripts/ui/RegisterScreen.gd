extends Control

const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

# The file itself is hidden for safety purposes, if you want to access it please contace me
const FILTERS = "res://private/filters.txt"

func _ready():
	SilentWolf.check_auth_ready()
	SilentWolf.Auth.sw_registration_complete.connect(_on_registration_complete)
	SilentWolf.Auth.sw_registration_user_pwd_complete.connect(_on_registration_user_pwd_complete)
	$CenterContainer/ContainerRect/Message.hide()

func _on_register_pressed() -> void:
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Register.disabled = true
	
	var player_name: String = $CenterContainer/ContainerRect/InputFields/UsernameEdit.text
	
	if _has_symbol(player_name):
		print(player_name, " HAS SYMBOLS")
		return
	
	var filtered_word_found := false
	var filtered_words_array: Array = []
	var filters = FileAccess.open(FILTERS, FileAccess.READ)
	var filtered_words = filters.get_as_text()
	var filtered_format = filtered_words.replace("\r", "")
	filtered_words_array = filtered_format.split("\n")
	
	for word in filtered_words_array:
		if player_name.to_lower().find(word.to_lower()) != -1:
			printerr("Player username strictly prohibited.")
			_has_filtered_word()
			filtered_word_found = true
			$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Register.disabled = false
			break
	
	if !filtered_word_found:
		_proceed_registration(player_name)
	
func _proceed_registration(player_name: String) -> void:
	var email: String # No email needed for Duskbreak accounts
	var password = $CenterContainer/ContainerRect/InputFields/PwEdit.text
	var confirm_password = $CenterContainer/ContainerRect/InputFields/ConfirmPwEdit.text
	SilentWolf.Auth.register_player(player_name, email, password, confirm_password)
	show_processing_label("Processing...")

func _has_symbol(input_string: String) -> bool:
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z0-9]")  # Regular expression pattern to match non-alphanumeric characters
	
	if regex.search(input_string) != null:
		show_processing_label("Player username should not contain any symbols or special characters")
		return true  # String contains a symbol
	else:
		return false  # String does not contain a symbol

func _has_filtered_word() -> void:
	show_processing_label("Chosen username contains strictly prohibited language. Please change it")

func _on_registration_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		registration_success()
	else:
		registration_failure(sw_result.error)


func _on_registration_user_pwd_complete(sw_result: Dictionary) -> void:
	if sw_result.success:
		registration_user_pwd_success()
	else:
		registration_failure(sw_result.error)


func registration_success() -> void:
	# redirect to configured scene (user is logged in after registration)
	var scene_name = SilentWolf.auth_config.redirect_to_scene
	# if doing email verification, open scene to confirm email address
	if ("email_confirmation_scene" in SilentWolf.auth_config) and (SilentWolf.auth_config.email_confirmation_scene) != "":
		SWLogger.info("registration succeeded, waiting for email verification...")
		scene_name = SilentWolf.auth_config.email_confirmation_scene
	else:
		SWLogger.info("registration succeeded, logged in player: " + str(SilentWolf.Auth.logged_in_player))
	
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Register.disabled = true
	UserData.send_user_data(str(SilentWolf.Auth.logged_in_player), true, true)
	show_processing_label("Registration succeeded, logged in player: " + str(SilentWolf.Auth.logged_in_player))


func registration_user_pwd_success() -> void:
	pass


func registration_failure(error: String) -> void:
	hide_processing_label()
	$CenterContainer/ContainerRect/CenterContainer/VBoxContainer/MainLabel/Buttons/Register.disabled = false
	$CenterContainer/ContainerRect/Message/MessageLabel.text = error
	$CenterContainer/ContainerRect/Message.show()


func _on_back_home_pressed() -> void:
	Scenes.to_scene("res://scenes/ui/start_menu.tscn")


func show_processing_label(info: String) -> void:
	$CenterContainer/ContainerRect/Message/MessageLabel.text = info
	$CenterContainer/ContainerRect/Message.show()


func hide_processing_label() -> void:
	$CenterContainer/ContainerRect/Message.hide()

func _new_tip(text: String) -> void:
	var timer: Timer = $CenterContainer/ContainerRect/InputFields/Tip/TipVisibility
	$CenterContainer/ContainerRect/InputFields/Tip.show()
	$CenterContainer/ContainerRect/InputFields/Tip.text = text
	
	if !timer.is_stopped():
		timer.stop()
		await get_tree().process_frame
		timer.start()
	else:
		timer.start()

func _on_username_edit_mouse_entered() -> void:
	_new_tip("Username should contain at least 6 characters (letters or numbers ONLY) with no spaces.")

func _on_pw_edit_mouse_entered() -> void:
	_new_tip("Password should have minimum 8 characters, uppercase, lowercase, numbers, and OPTIONALLY special characters.")

func _on_tip_visibility_timeout() -> void:
	$CenterContainer/ContainerRect/InputFields/Tip.hide()
