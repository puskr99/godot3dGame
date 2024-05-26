extends "res://src/player/player.gd"

var target_position: Vector3

const SPEED = 0.5
const STOP_DISTANCE = 1.0


func _ready():
	randomize()
	move_to_random_position()


func move_to_random_position():
	var map_width = 200
	var map_depth = 200
	
	var random_x = randf() * map_width - map_width / 2
	var random_z = randf() * map_depth - map_depth / 2

	target_position = Vector3(random_x, 0, random_z)


func _process(delta):
	move_towards_target(delta)


func move_towards_target(delta):
	var direction = (target_position - position).normalized()
	velocity = direction * SPEED
	
	animation_player.play("walking")
	
	look_at(target_position + direction)
	
#	look_at(Vector3(target_position.x, global_transform.origin.y, target_position.z))
	
	move_and_slide()
	
	if position.distance_to(target_position) < STOP_DISTANCE:
		animation_player.stop()
		move_to_random_position()
