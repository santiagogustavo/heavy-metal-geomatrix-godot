extends CharacterBody3D
class_name Player

@export_subgroup("Properties")
@export var health = 100

@export_subgroup("Controls")
@export var LOOK_CLAMP = 60

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera
@onready var camera_collider = $CameraPivot/CameraCollider
@onready var camera_target_raycast = $CameraPivot/TargetRaycast

@onready var character_controller = $CharacterController
@onready var animation_tree = $CharacterController/AnimationTree
@onready var sound_tree = $CharacterController/SoundAnimationTree
@onready var sound_attack_tree = $CharacterController/SoundAttackTree
@onready var dash_particle = $Dash
@onready var inventory_manager: InventoryManager = $InventoryManager

var is_walking = false
var is_dashing = false
var is_aiming = false
var is_shooting = false
var is_attacking = false
var is_jumping = false
var is_picking_up = false
var is_pickup_collided = false
var is_double_jumping = false
var is_dropping = false
var input_direction = Vector2.ZERO
var input_look = Vector2.ZERO

var new_rotation = Vector3.ZERO
var shoot_target = Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const dash_duration = 1

func _ready():
	GameManager.add_player(self)
	move_and_slide()

func _physics_process(delta):
	compute_gravity(delta)
	compute_movement()

func _input(event):
	if event is InputEventMouseMotion:
		new_rotation.y += deg_to_rad(-event.relative.x) * InputSettingsManager.mouse_horizontal_sensitivity
		new_rotation.x += deg_to_rad(-event.relative.y) * InputSettingsManager.mouse_vertical_sensitivity
		input_look.x = event.relative.x / 20

func _process(_delta):
	if GameManager.is_game_paused:
		return
	
	# VARIABLES AND MOTION
	set_sound_variables()
	set_animator_variables()
	set_camera_variables()
	set_inventory_items_variables()
	update_rotation_smoothing()
	move_and_slide()
	
	# COMPUTE FOR NEXT FRAME
	compute_look_stick()
	update_look_and_aim()
	update_dash()
	update_shoot()
	update_attack()
	update_pickup()
	update_camera_clamp()
	update_camera_collision()
	update_camera_target()
	clear_frame_variables()

func _exit_tree():
	GameManager.remove_player(get_rid())

func dash_stop():
	is_dashing = false
	
func update_dash():
	if dash_particle:
		dash_particle.emitting = is_dashing
		dash_particle.process_material.direction = -Vector3(input_direction.x, clampf(velocity.y / gravity, -1, 1), input_direction.y)

	if !is_walking:
		is_dashing = false
	
	if Input.is_action_just_pressed("dash") and !is_dashing and is_walking and is_on_floor():
		is_dashing = true
		get_tree().create_timer(dash_duration).timeout.connect(dash_stop)

func update_pickup():
	is_picking_up = (
		Input.is_action_just_pressed("pickup")
		and is_pickup_collided
		and !animation_tree.is_current_node_shooting()
		and !animation_tree.is_current_node_attacking()
	)

func update_shoot():
	is_shooting = Input.is_action_pressed("shoot")

func update_attack():
	is_attacking = Input.is_action_just_pressed("shoot")

func update_look_and_aim():
	input_look.y = -rad_to_deg(camera_pivot.rotation.x) / 90
	is_aiming = Input.is_action_pressed("aim")

func update_camera_clamp():
	new_rotation.x = clamp(new_rotation.x, -deg_to_rad(LOOK_CLAMP), deg_to_rad(LOOK_CLAMP))

func update_camera_collision():
	if camera_collider.is_colliding():
		camera.global_transform.origin = lerp(
			camera.global_transform.origin,
			camera_collider.get_collision_point(),
			0.1
		)
	else:
		camera.global_transform.origin = camera_collider.global_transform.origin

func update_camera_target():
	if camera_target_raycast.is_colliding():
		var point = camera_target_raycast.get_collision_point()
		shoot_target = point

func update_rotation_smoothing():
	if InputSettingsManager.look_smoothing_enabled:
		rotation.y = lerp_angle(rotation.y, new_rotation.y, InputSettingsManager.look_smoothing_intensity)
		camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x, new_rotation.x, InputSettingsManager.look_smoothing_intensity)
	else:
		rotation.y = new_rotation.y
		camera_pivot.rotation.x = new_rotation.x

func compute_look_stick():
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	look_dir = look_dir.normalized()
	input_look.x = look_dir.x * 0.6
	new_rotation.y += deg_to_rad(-look_dir.x) * InputSettingsManager.stick_horizontal_sensitivity
	new_rotation.x += deg_to_rad(-look_dir.y) * InputSettingsManager.stick_vertical_sensitivity

func compute_movement():
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	var current_speed = character_controller.speed
	if is_dashing and (!inventory_manager.has_jetpack or !inventory_manager.jetpack_has_fuel):
		current_speed = character_controller.dashing_speed
	elif is_dashing and inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel:
		current_speed = character_controller.jetpack_dashing_speed
	
	if direction.length():
		is_walking = true
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		is_walking = false
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

func compute_gravity(delta):
	velocity.y -= character_controller.weight * gravity * delta
	if is_on_floor():
		is_jumping = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			is_jumping = true
			velocity.y = character_controller.jump_height
		elif inventory_manager.has_jetpack:
			is_double_jumping = true
			if inventory_manager.jetpack_has_fuel:
				velocity.y = character_controller.jump_height

func clear_frame_variables():
	is_double_jumping = false

func set_camera_variables():
	camera.has_jetpack = inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel
	camera.is_dashing = is_dashing
	camera.is_aiming = is_aiming
	
func set_sound_variables():
	sound_tree.is_walking = is_walking
	sound_tree.is_jumping = is_jumping
	sound_tree.is_dashing = is_dashing
	sound_tree.is_picking_up = is_picking_up
	sound_tree.is_on_floor = is_on_floor()
	sound_attack_tree.equip_type = inventory_manager.equip_type
	sound_attack_tree.is_current_node_attacking = animation_tree.is_current_node_attacking()
	sound_attack_tree.current_animation = animation_tree.get_current_upper_body_animation()

func set_animator_variables():
	if inventory_manager.right_hand_instance != null and inventory_manager.right_hand_instance is GunController:
		animation_tree.is_shooting_locked = inventory_manager.right_hand_instance.is_shooting_locked
	animation_tree.equip = inventory_manager.equip_type
	animation_tree.direction = input_direction
	animation_tree.look = input_look
	animation_tree.is_dashing = is_dashing
	animation_tree.is_jumping = is_jumping
	animation_tree.is_double_jumping = is_double_jumping && inventory_manager.jetpack_has_fuel
	animation_tree.is_aiming = is_aiming
	animation_tree.is_gun_shooting = inventory_manager.is_gun_shooting
	animation_tree.is_shooting = is_shooting
	animation_tree.is_bursting = inventory_manager.is_gun_bursting
	animation_tree.is_dropping = inventory_manager.is_dropping
	animation_tree.is_attacking = is_attacking
	animation_tree.is_picking_up = is_picking_up
	animation_tree.is_on_floor = is_on_floor()

func set_inventory_items_variables():
	if inventory_manager.body_instance:
		inventory_manager.body_instance.is_dashing = is_dashing
		inventory_manager.body_instance.is_double_jumping = is_double_jumping
	if inventory_manager.right_hand_instance != null:
		if inventory_manager.right_hand_instance is SwordController:
			inventory_manager.right_hand_instance.is_attacking = animation_tree.is_current_node_attacking()
		if inventory_manager.right_hand_instance is GunController:
			inventory_manager.right_hand_instance.is_shooting = is_shooting
			inventory_manager.right_hand_instance.target_point = shoot_target
