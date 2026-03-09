## Main Menu Screen
##
## The first screen the player sees. Has a title and Play/Quit buttons.

extends Control


func _ready() -> void:
	# Connect button signals
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	GameManager.start_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
