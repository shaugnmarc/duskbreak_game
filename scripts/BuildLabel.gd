extends Label

@export var date := 24
@export var month := 11
@export var year := 2023

func _ready() -> void:
	text = "Duskbreak_" + str(year) + "-" + str(month) + "-" + str(date)
#	var time_date := Time.get_datetime_string_from_system(true)
#	print(time_date)
#
#	text = "Duskbreak_" + _truncate_date_string(time_date) 
#
#func _truncate_date_string(orig_string: String) -> String:
#	var date_index = orig_string.find("T") # Find the position of T in the string
#	if date_index != -1:  # Check if T is found in the string
#		var truncated_string = orig_string.left(date_index)  # Extract the date part before 'T'
#		return truncated_string
#	else:
#		return orig_string  # Return the original string if T is not found
