## Door / Level Exit
##
## An Area2D that acts as the level exit. Can be locked or unlocked.
## When the player enters and the door is unlocked, emits level_completed.

extends Area2D

## Whether the door is locked (requires a key to open)
@export var locked: bool = false

## Signal emitted when the player successfully enters the door
signal level_completed

## Visual reference to change color when unlocked
@onready var visual: ColorRect = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visual()


## Unlock the door (called by key or button)
func unlock() -> void:
	locked = false
	_update_visual()


## Update the door color based on locked state
func _update_visual() -> void:
	if visual:
		if locked:
			visual.color = Color(0.5, 0.1, 0.1, 1.0)  # Dark red = locked
		else:
			visual.color = Color(0.1, 0.7, 0.2, 1.0)  # Green = unlocked/open


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not locked:
		level_completed.emit()
