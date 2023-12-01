extends CenterContainer
class_name Milestone

const MILESTONE_SCREEN = preload("res://scenes/ui/milestone_screen.tscn")
@export var milestone_max_kills: int = 300
@export var milestone_reqd_kills: int = 100 # Every x kills will trigger a milestone

signal milestone_reached

func _process(delta: float) -> void:
	$MilestoneBar/KillCount.text = "x" + str(GameManager.enemy_kills)
func _ready() -> void:
	GameManager.kill_counter_changed.connect(_on_kill_counter_changed)
	GameManager.milestone = self
	
	$MilestoneBar.max_value = milestone_max_kills
	$MilestoneBar.value = 0

func _on_kill_counter_changed(value: int) -> void:
	$MilestoneBar.value = value

	if value > 0 and value <= milestone_max_kills and value % milestone_reqd_kills == 0:
		var milestone_counter = value / milestone_reqd_kills
		print("Milestone reached!", milestone_counter)
		milestone_reached.emit(milestone_counter)
		
		var screen_instance: Control = MILESTONE_SCREEN.instantiate()
		get_parent().get_parent().add_child(screen_instance)
