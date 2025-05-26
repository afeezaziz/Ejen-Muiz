# EjenMuiz.gd
extends CharacterBody3D

const SPEED = 3.5  # Adjusted for potentially more realistic walk
const RUN_SPEED_MULTIPLIER = 1.8
const MOUSE_SENSITIVITY = 0.003 # For Godot 4 (uses radians directly for rotation)
# const MOUSE_SENSITIVITY_DEG = 0.1 # For Godot 3.x (if using deg_to_rad)
const JUMP_VELOCITY = 5.0
const LOOK_SMOOTHING = 15.0 # For smoother model turning

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var follow_camera: Camera3D = $FollowCamera
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var model_node: Node3D = $Model # The root of your instanced GLB model

# Accessing the StateMachine playback parameter
# Ensure "parameters/playback" is the correct path to your StateMachine.
# If you named your StateMachine node something specific when creating the AnimationTree,
# the path might be different, e.g., animation_tree["parameters/MyStateMachineName/playback"]
# You can check this path in the AnimationTree panel by looking at the parameters.
@onready var animation_state_machine = animation_tree["parameters/playback"]

enum PlayerState { IDLE, WALK, RUN, JUMP_START, FALLING, LAND }
var current_state = PlayerState.IDLE
var previous_state = PlayerState.IDLE # To track state changes

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	animation_tree.active = true
	# Ensure initial animation state is set if not automatically handled by AnimationTree start node
	set_animation_state(PlayerState.IDLE)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate the MODEL node for horizontal look (left/right)
		model_node.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# For Godot 3.x: model_node.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY_DEG))

		# Rotate the Camera3D directly for vertical look (up/down)
		follow_camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# For Godot 3.x: follow_camera.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY_DEG))
		follow_camera.rotation.x = clamp(follow_camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	previous_state = current_state # Store state before physics calculations

	# --- Apply Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta
		if current_state != PlayerState.JUMP_START and current_state != PlayerState.FALLING : # If falling from edge or after jump peak
			current_state = PlayerState.FALLING
	elif current_state == PlayerState.FALLING or (current_state == PlayerState.JUMP_START and velocity.y <=0) : # Just landed or jump peaked and falling
		# This 'LAND' state is brief, mostly for triggering a land animation.
		# The AnimationTree should handle transitioning from 'Land' to 'Idle' or 'Walk' quickly.
		if current_state != PlayerState.LAND: # Avoid re-triggering land if already landing
			current_state = PlayerState.LAND

	# --- Handle Jump Input ---
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_state != PlayerState.JUMP_START:
		velocity.y = JUMP_VELOCITY
		current_state = PlayerState.JUMP_START

	# --- Handle Movement Input ---
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# Movement direction relative to camera, projected on horizontal plane
	var cam_transform = follow_camera.global_transform
	var forward_vector = -cam_transform.basis.z
	forward_vector.y = 0
	var right_vector = cam_transform.basis.x
	right_vector.y = 0
	
	var direction = (right_vector.normalized() * input_dir.x + forward_vector.normalized() *  -input_dir.y)

	var actual_speed = SPEED
	if Input.is_action_pressed("run") and is_on_floor() and direction != Vector3.ZERO:
		actual_speed *= RUN_SPEED_MULTIPLIER

	if is_on_floor() or current_state == PlayerState.LAND: # Allow ground movement logic
		if direction != Vector3.ZERO:
			velocity.x = direction.normalized().x * actual_speed
			velocity.z = direction.normalized().z * actual_speed

			if is_on_floor(): # Only update walk/run state if actually on floor and moving
				if Input.is_action_pressed("run"):
					current_state = PlayerState.RUN
				else:
					current_state = PlayerState.WALK
			
			# Rotate the model to face movement direction smoothly
			var target_angle = atan2(model_node.global_transform.basis.x.dot(direction), model_node.global_transform.basis.z.dot(direction))
			model_node.rotation.y = lerp_angle(model_node.rotation.y, model_node.rotation.y + target_angle, LOOK_SMOOTHING * delta)
			# A simpler look_at that might be more direct:
			# model_node.look_at(model_node.global_position + direction.normalized(), Vector3.UP)


		elif is_on_floor() and current_state != PlayerState.JUMP_START and current_state != PlayerState.LAND : # No movement input and on floor
			velocity.x = move_toward(velocity.x, 0, actual_speed * delta * 10.0) # Stronger deceleration
			velocity.z = move_toward(velocity.z, 0, actual_speed * delta * 10.0)
			current_state = PlayerState.IDLE
		elif current_state == PlayerState.LAND: # After landing, if no input, go to idle
			if direction == Vector3.ZERO:
				current_state = PlayerState.IDLE


	# --- Update Animation State if it changed ---
	if current_state != previous_state:
		set_animation_state(current_state)

	move_and_slide()

func set_animation_state(new_state: PlayerState):
	match new_state:
		PlayerState.IDLE:
			animation_state_machine.travel("idle") # Use your exact animation name
		PlayerState.WALK:
			animation_state_machine.travel("walk")
		PlayerState.RUN:
			animation_state_machine.travel("run")
		PlayerState.JUMP_START:
			animation_state_machine.travel("jump_start") # e.g., jump take-off animation
		PlayerState.FALLING:
			animation_state_machine.travel("fall") # e.g., looping falling/in-air animation
		PlayerState.LAND:
			animation_state_machine.travel("land") # e.g., landing animation
			# The "land" animation should ideally be short.
			# The AnimationTree can then transition from "land" to "idle" automatically (At End).
			# Or, after a short delay here, you could force it back to IDLE if no movement input.
			# For MVP, let AnimationTree handle post-land transition.
	# print("Current animation state: ", PlayerState.keys()[new_state]) # For debugging


func _on_area_3d_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
