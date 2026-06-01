extends CanvasLayer

@onready var score_label: Label = $Background/Panel/VBoxContainer/ScoreLabel
@onready var highscore_label: Label = $Background/Panel/VBoxContainer/HighScoreLabel

func _ready() -> void:
	# Enable processing when paused (since the level pauses on game over)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect buttons
	$Background/Panel/VBoxContainer/RetryBtn.pressed.connect(_on_retry_pressed)
	$Background/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

func set_scores(score: int, high_score: int) -> void:
	score_label.text = "Final Score: " + str(score)
	highscore_label.text = "Best Score: " + str(high_score)

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")
