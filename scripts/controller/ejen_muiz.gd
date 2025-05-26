# EjenMuiz.gd
extends CharacterBody3D

const SPEED = 5.0
const MOUSE_SENSITIVITY = 0.1 # Adjust as needed
const JUMP_VELOCITY = 4.5 # Optional, if you want jump

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var follow_camera: Camera3D = $FollowCamera # Assuming camera is direct child
# If camera is nested deeper, adjust path: @onready var follow_camera: Camera3D = $Pivot/FollowCamera

func _ready():
	# Capture mouse for camera control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	# Mouse look (camera rotation around player)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate the CharacterBody3D for horizontal look (left/right)
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		# Rotate the Camera3D directly for vertical look (up/down)
		# Clamp the vertical rotation to avoid flipping over
		follow_camera.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		follow_camera.rotation.x = clamp(follow_camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	# Toggle mouse capture with Escape key
	if event.is_action_pressed("ui_cancel"): # "ui_cancel" is usually Escape
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump (Optional).
	# if Input.is_action_just_pressed("jump") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	# Transform the input direction based on the character's rotation (so forward is where character faces)
	var direction = (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5.0) # Apply some friction/deceleration
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 5.0)

	move_and_slide()
