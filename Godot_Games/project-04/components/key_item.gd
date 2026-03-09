## Key Item (Collectible)
##
## An Area2D that the player can pick up. When collected,
## it finds the Door in the level and unlocks it.

extends Area2D

## Signal emitted when the key is collected
signal collected


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		collected.emit()
		# Find the door in the scene tree and unlock it
		var door = get_tree().get_first_node_in_group("door")
		if door and door.has_method("unlock"):
			door.unlock()
		# Remove the key from the scene
		queue_free()
