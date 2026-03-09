## Level 4: "Look for a hidden switch"
##
## The door is locked. A nearly invisible button is hidden on the left wall.
## The player must explore and touch the wall to find it.
## Teaches exploration and hidden object interaction.

extends Node2D


func _ready() -> void:
	$Door.locked = true
	$Door.add_to_group("door")
	$Door.level_completed.connect(_on_level_completed)
	$HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": Look for a hidden switch"


func _on_level_completed() -> void:
	GameManager.next_level()
