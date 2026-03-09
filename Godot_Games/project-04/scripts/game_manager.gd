## GameManager (Autoload Singleton)
##
## Manages game flow: tracks current level, handles scene transitions,
## and provides global functions for navigating between menu, levels, and win screen.

extends Node

## Ordered list of level scene paths
var level_scenes: Array[String] = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn",
]

## Current level index (0-based)
var current_level: int = 0


## Start the game from Level 1
func start_game() -> void:
	current_level = 0
	_load_current_level()


## Advance to the next level, or show win screen if all levels are done
func next_level() -> void:
	current_level += 1
	if current_level >= level_scenes.size():
		# All levels completed — show win screen
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
	else:
		_load_current_level()


## Restart from Level 1
func restart_game() -> void:
	current_level = 0
	_load_current_level()


## Go back to the main menu
func go_to_menu() -> void:
	current_level = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


## Get the current level number (1-based, for display)
func get_level_number() -> int:
	return current_level + 1


## Get total number of levels
func get_total_levels() -> int:
	return level_scenes.size()


## Internal: load the scene for the current level index
func _load_current_level() -> void:
	get_tree().change_scene_to_file(level_scenes[current_level])
