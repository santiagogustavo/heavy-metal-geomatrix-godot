extends Node
class_name PlayerBrain

enum BrainState {
	Idle,
	Looking,
}

var state = BrainState.Idle

@onready var player: Player = get_node('..')
var new_rotation: Vector3 = Vector3.ZERO
var distance: float = 0
var direction: Vector3 = Vector3.ZERO
var is_walking: bool = false

func _process(delta: float) -> void:
	update_look()
	get_direction_to_target()
	get_distance_to_target()
	match state:
		BrainState.Idle:
			look_at_closest_enemy()
			move_towards_player(delta)

func update_look() -> void:
	player.rotation.y = new_rotation.y

func look_at_closest_enemy() -> void:
	var enemies: Array[Player] = GameManager.get_enemies(player.team.name)
	for enemy in enemies:
		player.target_position = enemy.global_position
		player.target_position.y += 1.25
		
func move_towards_player(delta: float) -> void:
	is_walking = distance >= 5
	if is_walking:
		direction = Vector3(0.0, 0.0, 1.0)
		var current_speed = player.character.speed
		player.global_position.x = move_toward(player.global_position.x, player.target_position.x, delta * current_speed / 2)
		player.global_position.z = move_toward(player.global_position.z, player.target_position.z, delta * current_speed / 2)
	else:
		direction = Vector3.ZERO

func get_distance_to_target() -> void:
	distance = player.global_transform.origin.distance_to(player.target_position)
	
func get_direction_to_target() -> void:
	direction = (player.target_position - player.global_position).normalized()
