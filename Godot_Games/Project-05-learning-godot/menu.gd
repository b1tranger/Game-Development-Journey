extends Control

@onready var bg_music: AudioStreamPlayer = $BackgroundMusic

func _ready() -> void:
	# Connect buttons
	$Background/Panel/VBoxContainer/GamesContainer/RunnerBtn.pressed.connect(_on_runner_pressed)
	$Background/Panel/VBoxContainer/GamesContainer/PlaceholderBtn.pressed.connect(_on_placeholder_pressed)
	$Background/Panel/VBoxContainer/QuitBtn.pressed.connect(_on_quit_pressed)
	
	# Load and play background music
	var bgm_stream = load("res://Assets/brackeys_platformer_assets/music/time_for_adventure.mp3")
	if bgm_stream:
		bg_music.stream = bgm_stream
		bg_music.play()

func _on_runner_pressed() -> void:
	get_tree().change_scene_to_file("res://runner_game/runner_game.tscn")

func _on_placeholder_pressed() -> void:
	get_tree().change_scene_to_file("res://chicken_game/chicken_game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
