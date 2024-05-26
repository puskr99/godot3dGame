extends CharacterBody3D

@export var walk_speed = 2.0
@export var run_speed = 4.0
@export var sensi_horiz = 0.2
@export var sensi_verti = 0.2

var gravity = 9.8
var speed
var is_running: bool = false
var is_kicking: bool = false
var is_fpp: bool = false

@onready var animation_player = $Visauls/base_player/AnimationPlayer
@onready var visauls = $Visauls
@onready var camera_mount = $CameraMount


func _ready() -> void:
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensi_horiz))
		visauls.rotate_y(deg_to_rad(event.relative.x * sensi_horiz))
		camera_mount.rotate_y(deg_to_rad(-event.relative.y * sensi_verti))


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
	if Input.is_key_pressed(KEY_SHIFT):
		speed = run_speed
		is_running = true
	else:
		speed = walk_speed
		is_running = false

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			visauls.look_at(position + direction)
			
			if is_running:
				AudioPlayer.play_footstep_sound(2.0)
				if animation_player.current_animation != "running":
					animation_player.play("running")
			
			else:
				AudioPlayer.play_footstep_sound()
				if animation_player.current_animation != "walking":
					animation_player.play("walking")
				
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			AudioPlayer.stop_footstep_sound()
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		is_fpp = !is_fpp
		_change_prespective()


func _change_prespective() -> void:
	if is_fpp:
		$CameraMount/Camera3D.position = Vector3(0, 0.64, 2.098)
	else:
		$CameraMount/Camera3D.position = Vector3(0, 0.64, 0.0)
