## Level 2: "Jump over the obstacle"
##
## A spike blocks the path to the door. The player must jump over it.
## Teaches jumping mechanics.

extends Node2D


func _ready() -> void:
	$Door.level_completed.connect(_on_level_completed)
	$HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": Jump over the obstacle"


func _on_level_completed() -> void:
	GameManager.next_level()
