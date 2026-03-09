## Hidden Button
##
## An Area2D that is nearly invisible. When the player touches it,
## it finds the Door in the level and unlocks it, then becomes visible.

extends Area2D

## Signal emitted when button is pressed
signal button_pressed


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Start nearly invisible
	$Visual.color = Color(0.35, 0.35, 0.4, 0.15)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		button_pressed.emit()
		# Make the button visible to show it was found
		$Visual.color = Color(0.0, 1.0, 0.5, 1.0)
		# Find the door in the scene tree and unlock it
		var door = get_tree().get_first_node_in_group("door")
		if door and door.has_method("unlock"):
			door.unlock()
