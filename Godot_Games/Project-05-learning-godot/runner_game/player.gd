extends CharacterBody2D

signal collided

const JUMP_VELOCITY = -500.0
const GRAVITY = 1400.0

# Textures
@onready var sprite: Sprite2D = $Sprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $JumpSFX

var RUN_TEX = preload("res://Assets/FREE_Samurai 2D Pixel Art v1.2/Sprites/RUN.png")
var IDLE_TEX = preload("res://Assets/FREE_Samurai 2D Pixel Art v1.2/Sprites/IDLE.png")

# Animation parameters
var current_anim = "run"
var anim_frame = 0.0
var anim_speed = 15.0 # FPS

func _ready() -> void:
	# Set initial sprite setup
	sprite.texture = RUN_TEX
	sprite.hframes = 16
	sprite.vframes = 1
	sprite.frame = 0
	
	# Add jump sound stream if needed
	var sfx_stream = load("res://Assets/brackeys_platformer_assets/sounds/jump.wav")
	if sfx_stream:
		jump_sfx.stream = sfx_stream

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y < 0:
			set_anim("jump")
		else:
			set_anim("fall")
	else:
		velocity.y = 0
		set_anim("run")

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			if jump_sfx:
				jump_sfx.play()

	move_and_slide()
	update_animation(delta)

func set_anim(anim: String) -> void:
	if current_anim == anim:
		return
	
	current_anim = anim
	anim_frame = 0.0
	
	match anim:
		"run":
			sprite.texture = RUN_TEX
			sprite.hframes = 16
		"jump":
			# Use frame from idle or run
			sprite.texture = IDLE_TEX
			sprite.hframes = 10
		"fall":
			sprite.texture = IDLE_TEX
			sprite.hframes = 10

func update_animation(delta: float) -> void:
	match current_anim:
		"run":
			anim_frame += anim_speed * delta
			if anim_frame >= 16.0:
				anim_frame = 0.0
			sprite.frame = int(anim_frame)
		"jump":
			# Let's show upward frames
			sprite.frame = 2 # Fixed jump visual frame
		"fall":
			# Let's show falling frame
			sprite.frame = 5 # Fixed fall visual frame
