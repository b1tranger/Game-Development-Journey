extends CanvasLayer

func _ready() -> void:
	# Enable processing when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	$Background/Panel/VBoxContainer/ResumeBtn.pressed.connect(_on_resume_pressed)
	$Background/Panel/VBoxContainer/RestartBtn.pressed.connect(_on_restart_pressed)
	$Background/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
