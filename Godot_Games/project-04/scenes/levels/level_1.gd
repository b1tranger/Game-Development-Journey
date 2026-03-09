## Level 1: "Just reach the door"
##
## The simplest level — just walk right to reach the door.
## Teaches the player basic movement controls.

extends Node2D


func _ready() -> void:
	# Connect the door's signal to advance to next level
	$Door.level_completed.connect(_on_level_completed)
	# Set the level/hint label
	$HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": Just reach the door"


func _on_level_completed() -> void:
	GameManager.next_level()
