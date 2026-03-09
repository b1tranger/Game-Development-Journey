## Level 5: "Sometimes doing nothing is the answer"
##
## The player must stand still for 3 seconds to unlock the door.
## Any movement resets the timer.
## Teaches patience and unconventional puzzle thinking.

extends Node2D

## Timer tracking how long the player has been still
var still_timer: float = 0.0

## How many seconds of standing still to unlock
var required_still_time: float = 3.0

## Whether the door has already been unlocked by standing still
var unlocked: bool = false

## Reference to the player for velocity checking
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	$Door.locked = true
	$Door.add_to_group("door")
	$Door.level_completed.connect(_on_level_completed)
	$HintLabel.text = "Level " + str(GameManager.get_level_number()) + ": Sometimes doing nothing is the answer"


func _process(delta: float) -> void:
	if unlocked:
		return

	# Check if player is basically still (very low velocity and on floor)
	if player and player.is_on_floor() and abs(player.velocity.x) < 5.0:
		still_timer += delta
		# Update hint to show progress
		var remaining = required_still_time - still_timer
		if remaining > 0:
			$ProgressLabel.text = "..." + str(snapped(remaining, 0.1)) + "s"
		if still_timer >= required_still_time:
			unlocked = true
			$Door.unlock()
			$ProgressLabel.text = "Door opened!"
	else:
		still_timer = 0.0
		$ProgressLabel.text = ""


func _on_level_completed() -> void:
	GameManager.next_level()
