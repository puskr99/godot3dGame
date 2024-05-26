extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemy: int = 10

var enemy_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	return
	spawn_enemy()
	spawn_player()


func spawn_enemy() -> void:
	for i in max_enemy:
		var enemy = enemy_scene.instantiate()
		enemy.position = $Player.position + Vector3(10, 0, 0)
		add_child(enemy)
		enemy_count += 1
		await get_tree().create_timer(randi_range(2, 5))


func spawn_player() -> void:
	pass
