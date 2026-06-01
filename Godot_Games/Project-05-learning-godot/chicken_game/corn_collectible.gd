extends Area3D

signal collected

# Visual effects configuration
@export var spin_speed = 2.0
@export var float_speed = 3.0
@export var float_amplitude = 0.12

var time: float = 0.0
var base_y: float = 0.5
var is_collected: bool = false

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# Randomize phase so multiple collectibles don't float in perfect unison
	time = randf_range(0.0, 10.0)
	base_y = position.y
	
	# Connect collision event
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time += delta
	
	# Rotate the golden corn seed
	mesh.rotate_y(spin_speed * delta)
	
	# Float up and down
	position.y = base_y + sin(time * float_speed) * float_amplitude

func _on_body_entered(body: Node3D) -> void:
	if is_collected:
		return
		
	# Check if the player touched it
	if body.name == "ChickenPlayer" or body.has_method("cluck"):
		is_collected = true
		
		# Spawn a premium 3D floating label
		spawn_floating_text()
		
		# Emit collected signal
		collected.emit()
		
		# Safely delete collectible
		queue_free()

func spawn_floating_text() -> void:
	# Create a temporary Label3D for standard 3D floaty popups
	var label = Label3D.new()
	label.text = "+1 Corn!"
	label.font_size = 36
	label.modulate = Color(1.0, 0.85, 0.2, 1.0) # Golden yellow text
	label.outline_modulate = Color(0.1, 0.1, 0.0, 1.0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Always face camera!
	label.position = global_position + Vector3(0, 0.5, 0)
	
	# Add the label directly to our parent world scene
	get_parent().add_child(label)
	
	# Animate the label floating upward and fading out
	var tween = label.create_tween()
	tween.set_parallel(true)
	# Float up by 1.2 meters over 0.8 seconds
	tween.tween_property(label, "position:y", label.position.y + 1.2, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Fade out modulate alpha to 0
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Free the label when animation completes
	tween.chain().tween_callback(label.queue_free)
