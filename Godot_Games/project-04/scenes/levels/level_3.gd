## Level 3: "The door is locked. Find the key"
##
## The door starts locked. A key is placed on a raised platform.
## The player must jump to collect the key, then reach the door.
## Teaches collectibles and object interaction.

extends Node2D


func _ready() -> void:
	$Door.locked = true
	$Door.add_to_group("door")
	$Door.level_completed.connect(_on_level_completed)
	$HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": The door is locked. Find the key"


func _on_level_completed() -> void:
	GameManager.next_level()
