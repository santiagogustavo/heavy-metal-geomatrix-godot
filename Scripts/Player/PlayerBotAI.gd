extends Node
class_name PlayerBotAI

enum AIState {
	Idle,
	FocusEnemy,
	Dead,
}

var state = AIState.Idle

var player: Player

var target_distance: float = 0
var target_position: Vector3 = Vector3.ZERO

var additive_velocity: Vector3 = Vector3.ZERO
var last_link_exit_location: Vector3 = Vector3.ZERO
var link_exit_reached_threshold: float = 2.0

var look_at_speed: float = 3.0

var can_dash: bool = true

func _init(init_player: Player) -> void:
	player = init_player

func _ready() -> void:
	player.navigation_agent.link_reached.connect(handle_navigation_link_reached)

func _process(delta: float) -> void:
	clear_frame_variables()
	update_look(delta)
	get_direction_to_target()
	compute_next_state()
	look_at_target_position()
	compute_closest_enemy()
	match state:
		AIState.Idle:
			clear_walking_variables()
			pass
		AIState.FocusEnemy:
			player.brain.is_walking = true
			compute_attack()
			move_towards_target()
			pass
		AIState.Dead:
			clear_walking_variables()
			pass

func clear_frame_variables() -> void:
	player.brain.is_jumping = false
	player.brain.is_shooting = false

func clear_walking_variables() -> void:
	player.brain.is_walking = false
	player.brain.is_dashing = false
	player.brain.direction = Vector3.ZERO
	player.brain.input_direction = Vector2.ZERO

func compute_next_state():
	if (
		GameManager.current_match.round_status == MatchManager.RoundStatus.Ended
		or GameManager.current_match.is_player_input_locked
	):
		state = AIState.Idle
		return
	if player.health == 0:
		state = AIState.Dead
		return
	if target_distance >= 5:
		state = AIState.FocusEnemy
	else:
		state = AIState.Idle

func update_look(delta: float) -> void:
	player.rotation.y = lerp_angle(
		player.rotation.y,
		player.brain.new_rotation.y,
		look_at_speed * delta
	)

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
	var distance_of_aim = abs(player.rotation.y - player.brain.new_rotation.y)
	player.brain.is_shooting = distance_of_aim < 0.05

func action_jump() -> void:
	player.brain.is_jumping = player.brain.is_on_floor

func handle_navigation_link_reached(details: Dictionary) -> void:
	var new_velocity: Vector3 = (
		details.link_exit_position - details.link_entry_position
	).normalized() * player.character.speed
	additive_velocity = new_velocity
	last_link_exit_location = details.link_exit_position
	action_jump()

func look_at_target_position() -> void:
	player.camera_pivot.look_at(target_position)
	player.brain.new_rotation = player.camera_pivot.global_rotation

func move_towards_target() -> void:
	if get_distance_to_target(last_link_exit_location) < link_exit_reached_threshold:
		additive_velocity = Vector3.ZERO
	if target_distance > 10 and can_dash:
		player.brain.is_dashing = true
		can_dash = false
		get_tree().create_timer(player.brain.dash_duration + 1.0).timeout.connect(func (): can_dash = true)
	var current_location: Vector3 = player.global_transform.origin
	var next_location: Vector3 = player.navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = (next_location - current_location).normalized() * player.current_speed
	player.velocity.x = new_velocity.x + additive_velocity.x
	player.velocity.z = new_velocity.z + additive_velocity.z

func set_navigation_target(target: Vector3) -> void:
	player.navigation_agent.target_position = target

func decompose_position_xz(pos: Vector3) -> Vector3:
	return Vector3(pos.x, 0.0, pos.z)

func get_distance_to_xz_target(target: Vector3) -> float:
	var player_position_xz: Vector3 = decompose_position_xz(player.global_transform.origin)
	var target_position_xz: Vector3 = decompose_position_xz(target)
	return player_position_xz.distance_to(target_position_xz)

func get_distance_to_target(target: Vector3) -> float:
	return player.global_transform.origin.distance_to(target)
	
func get_direction_to_target() -> void:
	player.brain.direction = Vector3(0.0, 0.0, 1.0)
	player.brain.input_direction = Vector2(0.0, -1.0)
	#direction = (target_position - player.global_position).normalized()
