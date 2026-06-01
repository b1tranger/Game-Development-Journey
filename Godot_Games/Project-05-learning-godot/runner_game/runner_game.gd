extends Node2D

const OBSTACLE_SCENE = preload("res://runner_game/obstacle.tscn")
const PAUSE_MENU_SCENE = preload("res://runner_game/pause_menu.tscn")
const GAME_OVER_MENU_SCENE = preload("res://runner_game/game_over_menu.tscn")

@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $SpawnTimer
@onready var hud_score_label: Label = $HUD/MarginContainer/HBoxContainer/ScoreLabel
@onready var hud_highscore_label: Label = $HUD/MarginContainer/HBoxContainer/HighScoreLabel
@onready var bg_music: AudioStreamPlayer = $BackgroundMusic
@onready var hurt_sfx: AudioStreamPlayer2D = $HurtSFX

# Scrolling floor components
@onready var floor1: StaticBody2D = $Floors/Floor1
@onready var floor2: StaticBody2D = $Floors/Floor2

var base_speed = 350.0
var speed = 350.0
var score = 0.0
var high_score = 0
var is_game_over = false

const FLOOR_WIDTH = 1200.0

func _ready() -> void:
	randomize()
	load_high_score()
	hud_highscore_label.text = "High: " + str(high_score)
	
	# Configure spawning timer
	spawn_timer.wait_time = randf_range(1.5, 2.8)
	spawn_timer.timeout.connect(_on_spawn_timeout)
	spawn_timer.start()
	
	# Load BGM & SFX
	var bgm_stream = load("res://Assets/brackeys_platformer_assets/music/time_for_adventure.mp3")
	if bgm_stream:
		bg_music.stream = bgm_stream
		bg_music.play()
		
	var hurt_stream = load("res://Assets/brackeys_platformer_assets/sounds/hurt.wav")
	if hurt_stream:
		hurt_sfx.stream = hurt_stream

func _process(delta: float) -> void:
	if is_game_over:
		return
		
	# Gradual speed increase over time
	speed = base_speed + (score * 1.5)
	
	# Scroll floors
	floor1.position.x -= speed * delta
	floor2.position.x -= speed * delta
	
	if floor1.position.x <= -FLOOR_WIDTH:
		floor1.position.x = floor2.position.x + FLOOR_WIDTH
	if floor2.position.x <= -FLOOR_WIDTH:
		floor2.position.x = floor1.position.x + FLOOR_WIDTH
		
	# Increase Score
	score += delta * 10.0
	hud_score_label.text = "Score: " + str(int(score))
	
	# ESC to Pause
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()

func _on_spawn_timeout() -> void:
	if is_game_over:
		return
		
	# Spawn a new obstacle
	var obs = OBSTACLE_SCENE.instantiate()
	obs.position = Vector2(1250, 480) # Spawn off-screen
	obs.speed = speed
	add_child(obs)
	
	# Dynamic randomized next spawn interval based on current speed
	var min_time = clamp(1.2 - (speed * 0.0005), 0.8, 1.5)
	var max_time = clamp(2.5 - (speed * 0.0008), 1.4, 2.5)
	spawn_timer.wait_time = randf_range(min_time, max_time)
	spawn_timer.start()

func pause_game() -> void:
	get_tree().paused = true
	var pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)

func game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	get_tree().paused = true
	
	# Play explosion or hurt sound
	if hurt_sfx:
		hurt_sfx.play()
	if bg_music:
		bg_music.stop()
		
	# Check Highscore
	var int_score = int(score)
	if int_score > high_score:
		high_score = int_score
		save_high_score()
		
	# Instantiate Game Over Menu
	var game_over_menu = GAME_OVER_MENU_SCENE.instantiate()
	add_child(game_over_menu)
	game_over_menu.set_scores(int_score, high_score)

# Save/Load System
func load_high_score() -> void:
	var file = FileAccess.open("user://highscore.save", FileAccess.READ)
	if file:
		high_score = file.get_32()
		file.close()
	else:
		high_score = 0

func save_high_score() -> void:
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()
