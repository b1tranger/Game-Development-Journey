extends Area2D

const GREEN_SLIME = preload("res://Assets/brackeys_platformer_assets/sprites/slime_green.png")
const PURPLE_SLIME = preload("res://Assets/brackeys_platformer_assets/sprites/slime_purple.png")

@onready var sprite: Sprite2D = $Sprite2D

var speed = 350.0
var anim_frame = 0.0
var anim_speed = 8.0 # FPS

func _ready() -> void:
	# Randomly choose green or purple slime
	if randf() > 0.5:
		sprite.texture = GREEN_SLIME
	else:
		sprite.texture = PURPLE_SLIME
		
	sprite.hframes = 4
	sprite.vframes = 3
	# Start on frame 0
	sprite.frame = 0
	
	# Connect signal for collision
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Move left
	position.x -= speed * delta
	
	# Animate slime walk (frames 0 to 3)
	anim_frame += anim_speed * delta
	if anim_frame >= 4.0:
		anim_frame = 0.0
	sprite.frame = int(anim_frame)

	# Clean up when off-screen
	if position.x < -100:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		if body.has_method("collided") or body.has_signal("collided") or true:
			# Emit or call game over in the game controller
			var game = get_tree().current_scene
			if game and game.has_method("game_over"):
				game.game_over()
