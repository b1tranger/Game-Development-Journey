## Spike / Hazard
##
## An Area2D that kills the player on contact.
## The player will respawn at their spawn position.

extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("respawn"):
		body.respawn()
