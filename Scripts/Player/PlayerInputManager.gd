extends Node3D
class_name PlayerInputManager

signal lock_on

var type: Player.PlayerType

@export_subgroup("Controls")
@export_range(45, 90) var look_clamp: int = 60

@export_subgroup("Inputs")
var is_aiming: bool = false
var is_walking: bool = false
var is_dashing: bool = false
var is_jumping: bool = false
var is_double_jumping: bool = false
var is_shooting: bool = false
var is_attacking: bool = false
var is_picking_up: bool = false

# References
var is_on_floor: bool = true
var can_double_jump: bool = false
var can_pickup: bool = false
var camera_pivot: Node3D

# Externals
var is_locked_on: bool = false
var player: Player

# Internals
var process_input: bool = true

var direction: Vector3 = Vector3.ZERO
var input_direction: Vector2 = Vector2.ZERO
var input_look: Vector2 = Vector2.ZERO

var new_rotation_factor: Vector3 = Vector3.ZERO
var new_rotation: Vector3 = Vector3.ZERO

var target_raycast: RayCast3D
var aim_assist_raycast: RayCast3D

var dash_duration: float = 1.0

func _init(player_type: Player.PlayerType):
	type = player_type

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
		is_aiming = Input.is_action_pressed("aim")
		new_rotation += new_rotation_factor
		compute_look_stick()
		compute_movement()
		compute_shoot_and_attack()
		compute_pickup()
		compute_lock_on()
	else:
		is_shooting = false
		is_attacking = false
		is_aiming = false
		input_direction = Vector2.ZERO
		direction = Vector3.ZERO
		is_walking = false

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
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if direction.length():
		is_walking = true
	else:
		is_walking = false
	update_dash()

func compute_look_stick() -> void:
	if is_locked_on:
		return
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down", 0.2)
	input_look.x = look_dir.x * 0.6
	new_rotation_factor.y = deg_to_rad(-look_dir.x) * InputSettingsManager.stick_horizontal_sensitivity * get_relative_zoom_factor()
	new_rotation_factor.x = deg_to_rad(-look_dir.y) * InputSettingsManager.stick_vertical_sensitivity * get_relative_zoom_factor()

func compute_jump() -> void:
	is_jumping = Input.is_action_just_pressed("jump") and is_on_floor
	is_double_jumping = Input.is_action_just_pressed("jump") and !is_on_floor and can_double_jump

func compute_shoot_and_attack() -> void:
	is_shooting = Input.is_action_pressed("shoot")
	is_attacking = Input.is_action_just_pressed("shoot")

func compute_lock_on() -> void:
	if Input.is_action_just_pressed("lock_on"):
		lock_on.emit()

func update_look_and_aim(delta: float) -> void:
	input_look.y = -rad_to_deg(camera_pivot.rotation.x) / 90
	update_aim_assist(delta)
	update_rotation_smoothing()
	update_camera_clamp()

func update_camera_clamp() -> void:
	new_rotation.x = clamp(new_rotation.x, -deg_to_rad(look_clamp), deg_to_rad(look_clamp))

func is_target_player() -> bool:
	if target_raycast and target_raycast.is_colliding():
		var collider: PhysicsBody3D = target_raycast.get_collider()
		var layer = collider.collision_layer as Definitions.SurfaceType
		return layer == Definitions.SurfaceType.Player
	return false

func update_aim_assist(delta: float) -> void:
	if !InputSettingsManager.aim_assist_enabled:
		return
	if is_target_player():
		var collider: PhysicsBody3D = target_raycast.get_collider()
		aim_assist_raycast.look_at(collider.global_transform.origin, Vector3.UP)
		aim_assist_raycast.rotation_degrees.y += 180
		new_rotation_factor /= 1.5
		rotation.y = lerp_angle(
			rotation.y,
			new_rotation.y + aim_assist_raycast.rotation.y,
			delta,
		)
		camera_pivot.rotation.x = lerp_angle(
			camera_pivot.rotation.x,
			new_rotation.x + aim_assist_raycast.rotation.x,
			delta,
		)

func update_rotation_smoothing() -> void:
	if InputSettingsManager.look_smoothing_enabled and !is_target_player():
		rotation.y = lerp_angle(
			rotation.y,
			new_rotation.y,
			InputSettingsManager.look_smoothing_intensity
		)
		camera_pivot.rotation.x = lerp_angle(
			camera_pivot.rotation.x,
			new_rotation.x,
			InputSettingsManager.look_smoothing_intensity
		)
	else:
		rotation.y = new_rotation.y
		camera_pivot.rotation.x = new_rotation.x

func get_relative_zoom_factor() -> float:
	if !player or !player.inventory_manager:
		return 1
	var zoom_factor: float = player.inventory_manager.zoom_factor
	return (1.0 / zoom_factor) if is_aiming else 1.0

func update_dash() -> void:
	if !is_walking:
		is_dashing = false
	
	if Input.is_action_just_pressed("dash") and !is_dashing and is_walking and is_on_floor:
		is_dashing = true
		get_tree().create_timer(dash_duration).timeout.connect(func (): is_dashing = false)

func compute_pickup():
	is_picking_up = Input.is_action_just_pressed("pickup") and can_pickup
