## Win Screen
##
## Shown after the player completes all levels.
## Offers "Play Again" and "Main Menu" buttons.

extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayAgainButton.pressed.connect(_on_play_again_pressed)
	$CenterContainer/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)


func _on_play_again_pressed() -> void:
	GameManager.restart_game()


func _on_menu_pressed() -> void:
	GameManager.go_to_menu()
