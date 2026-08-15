extends Node
class_name PlayerBotAI

enum Difficulty {
	Easy,
	Normal,
	Hard,
}

enum AIState {
	Idle,
	Advance,
	Retreat,
	Pickup,
	Dead,
}

enum TargetType {
	Enemy,
	Pickup
}

enum DetectorPosition {
	Front,
	Left,
	Right,
}

var state = AIState.Idle

var player: Player

var target_type: TargetType = TargetType.Enemy
var target_distance: float = 0.0
var target_position: Vector3 = Vector3.ZERO

var enemy_distance: float = 0.0
var enemy_position: Vector3 = Vector3.ZERO

var closest_pickup: Pickup
var closest_pickup_distance: float = 0.0
var closest_pickup_position: Vector3 = Vector3.ZERO

var additive_velocity: Vector3 = Vector3.ZERO
var last_link_exit_location: Vector3 = Vector3.ZERO
var link_exit_reached_threshold: float = 1.0

var look_at_speed_min: float = 3.0
var look_at_speed_max: float = 17.0

var can_dash: bool = true

# Difficulty parameters
@export var difficulty: int = Difficulty.Normal
@export var aim_tolerance: float = 0.05
@export var reaction_delay: float = 0.0
@export var dash_distance_threshold: float = 10.0
@export var pickup_priority_modifier: float = 1.0
@export var movement_variance: float = 0.0

@export var aim_time: float = 0.0
@export var state_change_cooldown: float = 0.0

var _last_reaction_time: float = 0.0
var _last_state_change_time: float = 0.0
var _aim_start_time: float = 0.0

func set_difficulty(level: int) -> void:
	difficulty = level
	apply_difficulty_settings()

func apply_difficulty_settings() -> void:
	match difficulty:
		Difficulty.Easy:
			aim_tolerance = 0.12
			reaction_delay = 0.35
			dash_distance_threshold = 14.0
			pickup_priority_modifier = 0.6
			movement_variance = 0.35
			aim_time = 0.6
			state_change_cooldown = 0.6
		Difficulty.Normal:
			aim_tolerance = 0.06
			reaction_delay = 0.18
			dash_distance_threshold = 10.0
			pickup_priority_modifier = 1.0
			movement_variance = 0.15
			aim_time = 0.35
			state_change_cooldown = 0.35
		Difficulty.Hard:
			aim_tolerance = 0.03
			reaction_delay = 0.08
			dash_distance_threshold = 7.0
			pickup_priority_modifier = 1.4
			movement_variance = 0.05
			aim_time = 0.12
			state_change_cooldown = 0.12

var always_look_at_enemy: bool = false

var detector_collided_left: bool = false
var detector_collided_right: bool = false
var detector_collided_front: bool = false

func _init(init_player: Player) -> void:
	player = init_player

func _ready() -> void:
	player.detectors[0].body_entered.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Left, body, true)
	)
	player.detectors[0].body_exited.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Left, body, false)
	)
	player.detectors[1].body_entered.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Right, body, true)
	)
	player.detectors[1].body_exited.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Right, body, false)
	)
	player.detectors[2].body_entered.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Front, body, true)
	)
	player.detectors[2].body_exited.connect(func (body: Node3D):
		compute_detector_collision(DetectorPosition.Front, body, false)
	)
	player.navigation_agent.link_reached.connect(handle_navigation_link_reached)
	apply_difficulty_settings()

func _process(delta: float) -> void:
	clear_process_variables()
	common_behaviour(delta)
	compute_state_machine()

func _physics_process(delta: float) -> void:
	clear_physics_process_variables()
	compute_next_state()
	compute_state_machine_physics(delta)

func compute_state_machine() -> void:
	if has_reached_target() or !GameManager.current_match.is_ongoing:
		clear_walking_variables()
	match state:
		AIState.Advance:
			compute_attack()
			pass
		AIState.Retreat:
			compute_attack()
			pass
		AIState.Pickup:
			compute_pickup()
			pass

func compute_state_machine_physics(delta: float) -> void:
	match state:
		AIState.Idle:
			clear_walking_variables()
			pass
		AIState.Advance:
			advance_to_target(delta)
			pass
		AIState.Retreat:
			retreat_from_target()
			pass
		AIState.Pickup:
			compute_pickup()
			advance_to_target(delta)
			pass
		AIState.Dead:
			clear_walking_variables()
			pass

func compute_next_state():
	var has_gun: bool = player.inventory_manager.right_hand_instance != null
	var has_melee: bool = player.inventory_manager.has_melee
	var is_closest_pickup_ranged: bool = (
		closest_pickup.equip_type == Definitions.EquipType.WeaponSingle
		or closest_pickup.equip_type == Definitions.EquipType.WeaponDouble
	) if closest_pickup else false
	var is_pickup_distance_viable: bool = (
		(closest_pickup_distance * pickup_priority_modifier) < enemy_distance
	) if closest_pickup else false
	var need_to_pickup: bool = (has_melee and is_closest_pickup_ranged) or !has_gun
	if (
		GameManager.current_match
		and (
			!GameManager.current_match.is_ongoing
			or GameManager.current_match.is_player_input_locked
		)
	):
		state = AIState.Idle
		return
	if player.health == 0:
		state = AIState.Dead
		return
	var desired_state: int
	var desired_target_type: TargetType
	if need_to_pickup and is_pickup_distance_viable:
		desired_state = AIState.Pickup
		desired_target_type = TargetType.Pickup
	else:
		desired_state = AIState.Advance
		desired_target_type = TargetType.Enemy

	var now = Time.get_ticks_msec()
	if desired_state != state:
		if now - _last_state_change_time >= state_change_cooldown:
			state = desired_state as AIState
			target_type = desired_target_type as TargetType
			_last_state_change_time = now
	else:
		target_type = desired_target_type as TargetType
	return
	#elif target_distance < 1.0:
		#state = AIState.Retreat

func common_behaviour(delta: float) -> void:
	update_look(delta)
	step_away_from_obstacle(delta)
	get_direction_to_target()
	compute_target()

func clear_process_variables() -> void:
	if player.player_input:
		player.player_input.virtual_shoot = false
		player.player_input.virtual_attack = false
	player.brain.is_shooting = false
	player.brain.is_attacking = false

func clear_physics_process_variables() -> void:
	if player.player_input:
		player.player_input.virtual_jump_just_pressed = false
		player.player_input.virtual_pickup_just_pressed = false
	player.brain.is_jumping = false
	player.brain.is_picking_up = false

func clear_walking_variables() -> void:
	if has_collided_with_an_obstacle() and GameManager.current_match.is_ongoing:
		return
	if player.player_input:
		player.player_input.virtual_move = Vector2.ZERO
	player.brain.is_walking = false
	player.brain.is_dashing = false
	player.brain.direction = Vector3.ZERO
	player.brain.input_direction = Vector2.ZERO
	player.velocity.x = 0
	player.velocity.z = 0

func update_look(delta: float) -> void:
	var clamped_distance: float = clamp(
		target_distance,
		Definitions.WeaponRange.Min,
		Definitions.WeaponRange.Max,
	)
	var max_distance_ratio: float = clamped_distance / Definitions.WeaponRange.Max
	var relative_look_speed: float = look_at_speed_min + look_at_speed_max - (max_distance_ratio * look_at_speed_max)
	player.rotation.y = lerp_angle(
		player.rotation.y,
		player.brain.new_rotation.y,
		relative_look_speed * delta
	)

func compute_target() -> void:
	compute_closest_enemy()
	compute_closest_pickup()
	if target_type == TargetType.Enemy:
		target_distance = enemy_distance
		target_position = enemy_position
	else:
		target_distance = closest_pickup_distance
		target_position = closest_pickup_position
	if always_look_at_enemy:
		look_at_target_position(enemy_position)
	else:
		look_at_target_position(target_position)
	set_navigation_target(target_position)

func compute_closest_enemy() -> void:
	if !GameManager.current_match or !GameManager.current_match.is_ongoing:
		return
	var enemies: Array[Player] = GameManager.get_enemies(player.team.name)
	enemy_position = get_closest_position(enemies)
	enemy_distance = get_distance_to_target(enemy_position)

func compute_closest_pickup() -> void:
	if !GameManager.current_level_config or !GameManager.current_level_config.pickup_spawner:
		return
	var pickups: Array[Node3D] = GameManager.current_level_config.pickup_spawner.spawned_pickups
	var filtered_pickups: Array[Node3D]
	for pickup in pickups:
		if pickup != null:
			filtered_pickups.append(pickup)
	closest_pickup_position = get_closest_position(filtered_pickups)
	closest_pickup_distance = get_distance_to_target(closest_pickup_position)
	closest_pickup = get_closest_node(filtered_pickups)

func compute_attack() -> void:
	var is_distance_reliable = target_distance <= player.inventory_manager.weapon_range
	if !is_distance_reliable:
		return
	var distance_of_aim = abs(player.rotation.y - player.brain.new_rotation.y)
	var effective_tolerance = aim_tolerance + randf() * movement_variance
	var can_shoot_condition = (
		distance_of_aim < effective_tolerance
		and !player.brain.is_movement_locked
		and !DebugCommands.is_pacifist
	)
	var now = Time.get_ticks_msec()
	if can_shoot_condition:
		if _aim_start_time == 0.0:
			_aim_start_time = now
		if now - _aim_start_time >= aim_time and (now - _last_reaction_time >= reaction_delay):
			_last_reaction_time = now
			if player.player_input:
				player.player_input.virtual_shoot = true
				player.player_input.virtual_attack = true
			player.brain.is_shooting = true
			player.brain.is_attacking = true
	else:
		_aim_start_time = 0.0
		if player.player_input:
			player.player_input.virtual_shoot = false
		player.brain.is_shooting = false
		player.brain.is_attacking = false

func compute_pickup() -> void:
	if player.player_input:
		player.player_input.virtual_pickup_just_pressed = player.is_pickup_collided
	player.brain.is_picking_up = player.is_pickup_collided

func compute_detector_collision(detector: DetectorPosition, body: Node3D, entered: bool) -> void:
	var is_collider_weapon: bool = body.collision_layer == Definitions.SurfaceType.Weapon
	var is_own_weapon: bool = is_collider_weapon and body is Item and (body as Item).player_rid == player.get_rid()
	match detector:
		DetectorPosition.Front:
			detector_collided_front = !is_own_weapon and entered
			return
		DetectorPosition.Left:
			detector_collided_left = !is_own_weapon and entered
			return
		DetectorPosition.Right:
			detector_collided_right = !is_own_weapon and entered
			return

func action_jump() -> void:
	# Trigger a jump: set the virtual one-shot and ensure immediate vertical velocity
	if player.player_input and player.is_on_floor():
		player.player_input.virtual_jump_just_pressed = true
		player.brain.is_jumping = true
		# apply immediate jump velocity so the jump isn't missed due to ordering
		player.velocity.y = player.character.jump_height

func handle_navigation_link_reached(details: Dictionary) -> void:
	last_link_exit_location = details.link_exit_position
	# give a short impulse via forces and trigger a jump via virtual input
	player.apply_force(additive_velocity)
	# Debug info to help reproduce missing jumps
	# If on floor, trigger jump immediately (avoid missing due to physics ordering)
	if player.player_input:
		if player.is_on_floor():
			player.player_input.virtual_jump_just_pressed = true
			player.brain.is_jumping = true
			player.velocity.y = player.character.jump_height
		elif player.brain.can_double_jump:
			player.player_input.virtual_jump_just_pressed = true
			player.brain.is_double_jumping = true
			player.velocity.y = player.character.jump_height

func look_at_target_position(target: Vector3) -> void:
	player.camera_pivot.look_at(target)
	player.brain.new_rotation = player.camera_pivot.global_rotation

func retreat_from_target() -> void:
	# drive input backwards
	player.brain.input_direction = Vector2(0, 1)
	if player.player_input:
		player.player_input.virtual_move = Vector2(0, 1)
	player.brain.is_walking = true

func has_collided_with_an_obstacle() -> bool:
	return detector_collided_front

func has_reached_target() -> bool:
	return (
		target_type == TargetType.Enemy
		and target_distance < player.inventory_manager.weapon_range
	)

func step_away_from_obstacle(_delta: float) -> void:
	if has_collided_with_an_obstacle():
		var sidestep_world = Vector3(0, 0, 2)
		if detector_collided_right:
			sidestep_world += Vector3(-1, 0, 0)
		else:
			sidestep_world += Vector3(1, 0, 0)
		sidestep_world = sidestep_world.normalized()
		player.brain.is_walking = true
		# convert world dir to local input for PlayerInputManager
		if player.player_input:
			var local = player.global_transform.basis.transposed() * (sidestep_world)
			var lv = Vector2(local.x, local.z)
			if lv.length() > 1.0:
				lv = lv.normalized()
			player.player_input.virtual_move = lv
	# movement applied by Player.compute_movement

func advance_to_target(_delta: float) -> void:
	if has_reached_target() or player.brain.is_movement_locked:
		clear_walking_variables()
		return
	player.brain.is_walking = true
	if target_distance > dash_distance_threshold and can_dash:
		if player.player_input:
			player.player_input.virtual_dash_just_pressed = true
		else:
			player.brain.is_dashing = true
		can_dash = false
		get_tree().create_timer(player.brain.dash_duration + 1.0).timeout.connect(func (): can_dash = true)
	var current_location: Vector3 = player.global_transform.origin
	var next_location: Vector3 = player.navigation_agent.get_next_path_position()
	var desired_world_dir: Vector3 = (next_location - current_location).normalized()
	# convert world dir to local input for PlayerInputManager
	if player.player_input:
		var local = player.global_transform.basis.inverse() * (desired_world_dir)
		var lv = Vector2(local.x, local.z)
		if lv.length() > 1.0:
			lv = lv.normalized()
		player.player_input.virtual_move = lv
		player.player_input.virtual_move = lv
	# additive_velocity already applied once on link reached; do not re-apply here

func set_navigation_target(target: Vector3) -> void:
	player.navigation_agent.target_position = target

func decompose_position_xz(pos: Vector3) -> Vector3:
	return Vector3(pos.x, 0.0, pos.z)

func get_closest_position(nodes: Array) -> Vector3:
	var closest_position: Vector3
	var closest_distance: float = -1
	for node: Node3D in nodes:
		var current_distance = get_distance_to_target(node.global_position)
		if closest_distance == -1 or current_distance < closest_distance:
			closest_distance = current_distance
			closest_position = node.global_position
	closest_position.y += 1.25
	return closest_position

func get_closest_node(nodes: Array) -> Node3D:
	var closest_node: Node3D
	var closest_distance: float = -1
	for node: Node3D in nodes:
		var current_distance = get_distance_to_target(node.global_position)
		if closest_distance == -1 or current_distance < closest_distance:
			closest_node = node
			closest_distance = current_distance
	return closest_node

func get_distance_to_xz_target(target: Vector3) -> float:
	var player_position_xz: Vector3 = decompose_position_xz(player.global_transform.origin)
	var target_position_xz: Vector3 = decompose_position_xz(target)
	return player_position_xz.distance_to(target_position_xz)

func get_distance_to_target(target: Vector3) -> float:
	return player.global_transform.origin.distance_to(target)
	
func get_direction_to_target() -> void:
	# face forward and move towards target in local input space
	player.brain.input_direction = Vector2(0.0, -1.0)
	if player.player_input:
		player.player_input.virtual_move = Vector2(0.0, -1.0)
