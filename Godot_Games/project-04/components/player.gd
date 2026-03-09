## Player Character
##
## A CharacterBody2D that handles horizontal movement and jumping.
## Uses Godot's built-in physics for gravity and collision.

extends CharacterBody2D

## Movement speed in pixels per second
@export var speed: float = 200.0

## Jump velocity (negative = upward)
#@export var jump_velocity: float = -350.0
@export var jump_velocity: float = -450.0

## Gravity multiplier
@export var gravity_multiplier: float = 1.0

## Signal emitted when player dies (hits spikes or falls off screen)
signal died

## Signal emitted when player collects a key
signal collected_key

## The spawn position to respawn at
var spawn_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Remember where we started so we can respawn here
	spawn_position = global_position


func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += get_gravity().y * gravity_multiplier * delta

	# --- Jump ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# --- Horizontal Movement ---
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
	else:
		# Slow down when no input (friction)
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)

	move_and_slide()

	# --- Fall off screen check ---
	if global_position.y > 600:
		_die()


## Called when the player should die and respawn
func _die() -> void:
	died.emit()
	respawn()


## Reset player to spawn position
func respawn() -> void:
	velocity = Vector2.ZERO
	global_position = spawn_position
