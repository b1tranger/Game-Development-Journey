extends Node3D

const CORN_SCENE = preload("res://chicken_game/corn_collectible.tscn")
const PAUSE_MENU_SCENE = preload("res://chicken_game/chicken_pause_menu.tscn")

@onready var collectibles_container: Node3D = $Collectibles
@onready var score_label: Label = $HUD/MarginContainer/TopPanel/MarginContainer/ScoreLabel
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var chew_sfx: AudioStreamPlayer = $ChewSFX

var score: int = 0
var max_corn_on_field: int = 5

func _ready() -> void:
	randomize()
	
	# Load BGM & Collection SFX
	var bgm_stream = load("res://Assets/brackeys_platformer_assets/music/time_for_adventure.mp3")
	if bgm_stream:
		bgm_player.stream = bgm_stream
		bgm_player.play()
		
	var chew_stream = load("res://Assets/brackeys_platformer_assets/sounds/coin.wav")
	if chew_stream:
		chew_sfx.stream = chew_stream
		chew_sfx.pitch_scale = 1.1 # slightly higher pitch for cute chewing/pecking SFX
		
	# Spawn initial batch of corn seeds scattered in the pasture
	for i in range(max_corn_on_field):
		spawn_corn()

func _process(delta: float) -> void:
	# ESC/Cancel to Pause
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()

# Spawn a golden corn seed at a random spot inside boundaries
func spawn_corn() -> void:
	var corn = CORN_SCENE.instantiate()
	
	# Keep corn inside pasture invisible boundaries (x/z range: -14 to 14)
	var rand_x = randf_range(-13.5, 13.5)
	var rand_z = randf_range(-13.5, 13.5)
	
	# Make sure it doesn't spawn exactly inside our rock obstacles
	while (Vector2(rand_x, rand_z) - Vector2(8.0, -8.0)).length() < 2.0 or (Vector2(rand_x, rand_z) - Vector2(-9.0, 7.0)).length() < 2.0:
		rand_x = randf_range(-13.5, 13.5)
		rand_z = randf_range(-13.5, 13.5)
		
	corn.position = Vector3(rand_x, 0.4, rand_z)
	
	# Connect signal to update score when eaten
	corn.collected.connect(_on_corn_collected)
	
	collectibles_container.add_child(corn)

func _on_corn_collected() -> void:
	# Play cute eating sound
	if chew_sfx:
		chew_sfx.play()
		
	# Increase score and update HUD label
	score += 1
	score_label.text = "Corn Gathered: " + str(score)
	
	# Smoothly pop the HUD label scale to give visual feedback
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Spawn a replacement corn elsewhere on the field
	spawn_corn()

func pause_game() -> void:
	# Open glassmorphic pause overlay and stop engine processing
	get_tree().paused = true
	var pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(pause_menu)
