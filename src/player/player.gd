extends CharacterBody3D

var speed
const WALK_SPEED = 2.0
const RUN_SPEED = 4.0
#const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.004
var is_running: bool = false

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var animation_player = $base_player/AnimationPlayer
@onready var head = $base_player
@onready var camera = $SpringArm3D/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


var is_kicking = false
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if is_on_floor():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if animation_player.current_animation != "kick":
				is_kicking = true
				animation_player.play("kick")
				await animation_player.animation_finished
				is_kicking = false
			
	if is_kicking:
		return
		
	# Handle Sprint.
	if Input.is_key_pressed(KEY_SPACE):
		speed = RUN_SPEED
		is_running = true
	else:
		speed = WALK_SPEED
		is_running = false

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			if is_running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
			
			else:
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
				
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, RUN_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

