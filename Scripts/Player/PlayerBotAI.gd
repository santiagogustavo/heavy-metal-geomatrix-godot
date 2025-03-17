extends Node
class_name PlayerBotAI

enum AIState {
	Idle,
	Looking,
	Dead,
}

var state = AIState.Idle

@onready var player: Player = get_node('..')
var new_rotation: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var is_walking: bool = false
var is_jumping: bool = false
var is_shooting: bool = true
var is_dashing: bool = false

var target_distance: float = 0
var target_position: Vector3 = Vector3.ZERO

var additive_velocity: Vector3 = Vector3.ZERO
var last_link_exit_location: Vector3 = Vector3.ZERO

func _ready() -> void:
	player.navigation_agent.link_reached.connect(handle_navigation_link_reached)

func _process(_delta: float) -> void:
	clear_frame_variables()
	update_look()
	get_direction_to_target()
	compute_next_state()
	if (GameManager.current_match and GameManager.current_match.is_player_input_locked):
		return
	match state:
		AIState.Idle:
			compute_closest_enemy()
			compute_attack()
			look_at_target_position()
			move_towards_target()
		AIState.Dead:
			pass

func clear_frame_variables() -> void:
	is_jumping = false

func compute_next_state():
	if player.health == 0:
		state = AIState.Dead

func update_look() -> void:
	player.rotation.y = new_rotation.y

func compute_closest_enemy() -> void:
	var enemies: Array[Player] = GameManager.get_enemies(player.team.name)
	var closest_position: Vector3
	var closest_distance: float = -1
	for enemy in enemies:
		var current_distance = get_distance_to_target(enemy.global_position)
		if closest_distance == -1 or current_distance < closest_distance:
			closest_distance = current_distance
			closest_position = enemy.global_position
	closest_position.y += 1.25
	target_distance = closest_distance
	target_position = closest_position
	set_navigation_target(target_position)

func compute_attack() -> void:
	is_shooting = true

func handle_navigation_link_reached(details: Dictionary) -> void:
	var new_velocity: Vector3 = (details.link_exit_position - details.link_entry_position).normalized() * player.character.speed
	additive_velocity = new_velocity
	last_link_exit_location = details.link_exit_position
	is_jumping = true

func look_at_target_position() -> void:
	player.camera_pivot.look_at(target_position)
	new_rotation = player.camera_pivot.global_rotation

func move_towards_target() -> void:
	if get_distance_to_target(last_link_exit_location) < 1.5:
		additive_velocity = Vector3.ZERO
	is_walking = target_distance >= 5
	if is_walking:
		var current_speed = player.character.speed
		var current_location: Vector3 = player.global_transform.origin
		var next_location: Vector3 = player.navigation_agent.get_next_path_position()
		var new_velocity: Vector3 = (next_location - current_location).normalized() * current_speed
		player.velocity.x = new_velocity.x + additive_velocity.x
		player.velocity.z = new_velocity.z + additive_velocity.z
	else:
		direction = Vector3.ZERO

func set_navigation_target(target: Vector3) -> void:
	player.navigation_agent.target_position = target

func get_distance_to_target(target: Vector3) -> float:
	return player.global_transform.origin.distance_to(target)
	
func get_direction_to_target() -> void:
	direction = Vector3(0.0, 0.0, 1.0)
	#direction = (target_position - player.global_position).normalized()
