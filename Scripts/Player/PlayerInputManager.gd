extends Node3D
class_name PlayerInputManager

signal lock_on

@export_subgroup("Controls")
@export_range(45, 90) var look_clamp: int = 60

# References
var camera_pivot: Node3D

# Externals
var is_locked_on: bool = false
var player: Player

# Internals
var process_input: bool = true
var input_look: Vector2 = Vector2.ZERO

var new_rotation_factor: Vector3 = Vector3.ZERO

var target_raycast: RayCast3D
var aim_assist_raycast: RayCast3D

func _init(init_player: Player):
	player = init_player

func _process(delta: float) -> void:
	set_process_input(
		process_input
		and !PauseMenuManager.is_menu_open
		and !DebugMenuManager.is_menu_open
		and (GameManager.current_match and !GameManager.current_match.is_player_input_locked)
	)
	_processed_input(delta)
	
func _processed_input(delta: float) -> void:
	update_look_and_aim(delta)
	if is_processing_input():
		player.brain.is_aiming = Input.is_action_pressed("aim")
		player.brain.new_rotation += new_rotation_factor
		compute_look_stick()
		compute_movement()
		compute_shoot_and_attack()
		compute_pickup()
		compute_lock_on()
	else:
		player.brain.is_shooting = false
		player.brain.is_attacking = false
		player.brain.is_aiming = false
		player.brain.input_direction = Vector2.ZERO
		player.brain.direction = Vector3.ZERO
		player.brain.is_walking = false

func _physics_process(_delta: float) -> void:
	if is_processing_input():
		_physics_processed_input()

func _physics_processed_input() -> void:
	compute_jump()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and !is_locked_on:
		new_rotation_factor.y = deg_to_rad(-event.relative.x) * InputSettingsManager.mouse_horizontal_sensitivity * get_relative_zoom_factor()
		new_rotation_factor.x = deg_to_rad(-event.relative.y) * InputSettingsManager.mouse_vertical_sensitivity * get_relative_zoom_factor()
		input_look.x = event.relative.x / 20

func compute_movement() -> void:
	player.brain.input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.brain.direction = (
		transform.basis
		* Vector3(player.brain.input_direction.x, 0, player.brain.input_direction.y)
	).normalized()
	if player.brain.direction.length():
		player.brain.is_walking = true
	else:
		player.brain.is_walking = false
	update_dash()

func compute_look_stick() -> void:
	if is_locked_on:
		return
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down", 0.2)
	input_look.x = look_dir.x * 0.6
	new_rotation_factor.y = deg_to_rad(-look_dir.x) * InputSettingsManager.stick_horizontal_sensitivity * get_relative_zoom_factor()
	new_rotation_factor.x = deg_to_rad(-look_dir.y) * InputSettingsManager.stick_vertical_sensitivity * get_relative_zoom_factor()

func compute_jump() -> void:
	player.brain.is_jumping = (
		Input.is_action_just_pressed("jump")
		and player.brain.is_on_floor
	)
	player.brain.is_double_jumping = (
		Input.is_action_just_pressed("jump")
		and !player.brain.is_on_floor
		and player.brain.can_double_jump
	)

func compute_shoot_and_attack() -> void:
	player.brain.is_shooting = Input.is_action_pressed("shoot")
	player.brain.is_attacking = Input.is_action_just_pressed("shoot")

func compute_lock_on() -> void:
	if Input.is_action_just_pressed("lock_on"):
		lock_on.emit()

func update_look_and_aim(delta: float) -> void:
	input_look.y = -rad_to_deg(camera_pivot.rotation.x) / 90
	update_aim_assist(delta)
	update_rotation_smoothing()
	update_camera_clamp()

func update_camera_clamp() -> void:
	player.brain.new_rotation.x = clamp(
		player.brain.new_rotation.x,
		-deg_to_rad(look_clamp),
		deg_to_rad(look_clamp)
	)

func is_target_player() -> bool:
	if target_raycast and target_raycast.is_colliding():
		var collider: PhysicsBody3D = target_raycast.get_collider()
		var layer = collider.collision_layer as Definitions.SurfaceType
		return layer == Definitions.SurfaceType.Hitbox
	return false

func update_aim_assist(delta: float) -> void:
	if !InputSettingsManager.aim_assist_enabled:
		return
	if is_target_player():
		var collider: PhysicsBody3D = target_raycast.get_collider()
		aim_assist_raycast.look_at(collider.global_transform.origin, Vector3.UP)
		aim_assist_raycast.rotation_degrees.y += 180
		new_rotation_factor /= 3.0
		rotation.y = lerp_angle(
			rotation.y,
			player.brain.new_rotation.y + aim_assist_raycast.rotation.y,
			delta,
		)
		camera_pivot.rotation.x = lerp_angle(
			camera_pivot.rotation.x,
			player.brain.new_rotation.x + aim_assist_raycast.rotation.x,
			delta,
		)

func update_rotation_smoothing() -> void:
	if InputSettingsManager.look_smoothing_enabled and !is_target_player():
		rotation.y = lerp_angle(
			rotation.y,
			player.brain.new_rotation.y,
			InputSettingsManager.look_smoothing_intensity
		)
		camera_pivot.rotation.x = lerp_angle(
			camera_pivot.rotation.x,
			player.brain.new_rotation.x,
			InputSettingsManager.look_smoothing_intensity
		)
	else:
		rotation.y = player.brain.new_rotation.y
		camera_pivot.rotation.x = player.brain.new_rotation.x

func get_relative_zoom_factor() -> float:
	if !player or !player.inventory_manager:
		return 1
	var zoom_factor: float = player.inventory_manager.zoom_factor
	return (1.0 / zoom_factor) if player.brain.is_aiming else 1.0

func update_dash() -> void:
	if (
		Input.is_action_just_pressed("dash")
		and !player.brain.is_dashing
		and player.brain.is_walking
		and player.brain.is_on_floor
	):
		player.brain.is_dashing = true

func compute_pickup():
	player.brain.is_picking_up = Input.is_action_just_pressed("pickup") and player.brain.can_pickup
