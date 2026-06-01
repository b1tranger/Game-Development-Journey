extends CharacterBody3D

# Movement configuration
@export var speed = 4.0
@export var jump_velocity = 4.5
@export var acceleration = 8.0
@export var deceleration = 10.0
@export var rotation_speed = 10.0

# Camera mouse sensitivity
@export var mouse_sensitivity = 0.003
@export var min_pitch = -1.0 # about -60 degrees
@export var max_pitch = 0.3  # about +15 degrees

# Node references
@onready var pivot: Node3D = $ModelPivot
@onready var camera_arm: SpringArm3D = $CameraArm
@onready var cluck_sfx: AudioStreamPlayer3D = $CluckSFX
@onready var jump_sfx: AudioStreamPlayer3D = $JumpSFX
@onready var step_sfx: AudioStreamPlayer3D = $StepSFX

# Gravity
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Animation tracking variables
var anim_time: float = 0.0
var walk_cycle: float = 0.0
var squash_stretch: Vector3 = Vector3(1.0, 1.0, 1.0)
var was_in_air: bool = false
var step_cooldown: float = 0.0

# Mouse control state
var mouse_captured: bool = true

func _ready() -> void:
	# Capture mouse by default
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Load SFX files
	var jump_stream = load("res://Assets/brackeys_platformer_assets/sounds/jump.wav")
	if jump_stream:
		jump_sfx.stream = jump_stream
		
	var cluck_stream = load("res://Assets/brackeys_platformer_assets/sounds/hurt.wav")
	if cluck_stream:
		cluck_sfx.stream = cluck_stream
		cluck_sfx.pitch_scale = 1.8 # Make it a high-pitched chicken chirp/cluck
		
	var step_stream = load("res://Assets/brackeys_platformer_assets/sounds/tap.wav")
	if step_stream:
		step_sfx.stream = step_stream
		step_sfx.pitch_scale = 1.3 # Light footsteps

func _unhandled_input(event: InputEvent) -> void:
	# Mouse orbiting controls
	if mouse_captured and event is InputEventMouseMotion:
		# Yaw (left-right rotation around player Y axis)
		camera_arm.rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Pitch (up-down camera arm rotation around X axis)
		var new_pitch = camera_arm.rotation.x - event.relative.y * mouse_sensitivity
		camera_arm.rotation.x = clamp(new_pitch, min_pitch, max_pitch)
		
	# Toggle mouse lock with left click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			mouse_captured = true

func _process(delta: float) -> void:
	# Check if mouse is captured
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_captured = true
	else:
		mouse_captured = false
		
	# Local keyboard clucking trigger
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if mouse_captured and not get_tree().paused:
			cluck()

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		was_in_air = true
	else:
		# Detect landing event to trigger squash squash-and-stretch
		if was_in_air:
			was_in_air = false
			# Landing squash: short, wide
			squash_stretch = Vector3(1.3, 0.7, 1.3)
			# Play landing sound
			if step_sfx:
				step_sfx.pitch_scale = 0.9
				step_sfx.play()
		
	# Handle jumping
	if Input.is_action_just_pressed("ui_select") and is_on_floor() and not get_tree().paused:
		velocity.y = jump_velocity
		# Jump stretch: tall, narrow
		squash_stretch = Vector3(0.7, 1.4, 0.7)
		if jump_sfx:
			jump_sfx.play()

	# Get input direction relative to camera
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Calculate move vector relative to camera look
	var camera_basis = camera_arm.global_basis
	var forward = camera_basis.z
	var right = camera_basis.x
	
	# Keep movement on XZ plane
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	
	var direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	if direction != Vector3.ZERO:
		# Accelerate towards direction
		var target_vel_x = direction.x * speed
		var target_vel_z = direction.z * speed
		velocity.x = move_toward(velocity.x, target_vel_x, acceleration * delta)
		velocity.z = move_toward(velocity.z, target_vel_z, acceleration * delta)
		
		# Rotate visual model smoothly to face move direction
		var target_angle = atan2(-direction.x, -direction.z)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, target_angle, rotation_speed * delta)
	else:
		# Decelerate to stop
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)

	move_and_slide()
	
	# --- Procedural Claymation Animation Engine ---
	anim_time += delta
	
	# Smoothly return squash-and-stretch to standard 1.0
	squash_stretch = squash_stretch.lerp(Vector3(1.0, 1.0, 1.0), 8.0 * delta)
	
	var current_horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor():
		if current_horizontal_speed > 0.1:
			# Walking: Bouncing walk waddle
			var walk_speed_factor = clamp(current_horizontal_speed / speed, 0.3, 1.5)
			walk_cycle += delta * 12.0 * walk_speed_factor
			
			# Up-and-down hop animation: sine wave (absolute value for hopping)
			var bounce_height = 0.15 * abs(sin(walk_cycle))
			pivot.position.y = bounce_height
			
			# Side-to-side waddle/tilt: cosine wave on Z rotation
			var tilt_angle = 0.18 * cos(walk_cycle)
			pivot.rotation.z = tilt_angle
			
			# Slight forward lean
			pivot.rotation.x = lerp_angle(pivot.rotation.x, 0.12, 10.0 * delta)
			
			# Sync step sound with the bottom of the bounce cycle (sin goes close to 0)
			step_cooldown -= delta
			if abs(sin(walk_cycle)) < 0.25 and step_cooldown <= 0.0:
				if step_sfx:
					step_sfx.pitch_scale = randf_range(1.2, 1.4)
					step_sfx.play()
				step_cooldown = 0.25 # Cooldown to prevent double step sounds
		else:
			# Idle: Subtle breathing scale and reset offsets
			walk_cycle = 0.0
			pivot.position.y = move_toward(pivot.position.y, 0.0, 8.0 * delta)
			pivot.rotation.z = lerp_angle(pivot.rotation.z, 0.0, 10.0 * delta)
			pivot.rotation.x = lerp_angle(pivot.rotation.x, 0.0, 10.0 * delta)
			
			# Idle breathe scaling (yoyo)
			var breathe = sin(anim_time * 3.5) * 0.015
			pivot.scale = Vector3(1.0 - breathe, 1.0 + breathe, 1.0 - breathe) * squash_stretch
			return # Skip standard scale overwrite below
	else:
		# In air: Reset offsets, stretching is handled by squash_stretch lerp
		pivot.position.y = move_toward(pivot.position.y, 0.0, 8.0 * delta)
		pivot.rotation.z = lerp_angle(pivot.rotation.z, 0.0, 10.0 * delta)
		
		# Pitch forward/back slightly depending on vertical velocity
		var air_lean = clamp(velocity.y * 0.05, -0.2, 0.2)
		pivot.rotation.x = lerp_angle(pivot.rotation.x, -air_lean, 10.0 * delta)
		
	# Apply final procedural squash and stretch to pivot scale
	pivot.scale = squash_stretch

# Trigger chicken cluck animation and sound
func cluck() -> void:
	if cluck_sfx and not cluck_sfx.playing:
		cluck_sfx.pitch_scale = randf_range(1.6, 2.0)
		cluck_sfx.play()
		
		# Cluck squash and stretch trigger: stretch tall, tilt head back slightly
		squash_stretch = Vector3(0.8, 1.3, 0.8)
		pivot.rotation.x = -0.3 # Look upward to crow/cluck
