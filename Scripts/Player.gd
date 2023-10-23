extends CharacterBody3D
class_name Player

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera
@onready var camera_collider = $CameraPivot/CameraCollider

@onready var animation_tree = $CharacterController/AnimationTree
@onready var sound_tree = $CharacterController/SoundAnimationTree
@onready var sound_attack_tree = $CharacterController/SoundAttackTree
@onready var dash_particle = $Dash
@onready var inventory_manager: InventoryManager = $InventoryManager

@export_subgroup("Physics")
@export var speed = 7.5
@export var dashing_speed = 10
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10
@export var weight = 2.5

@export_subgroup("Controls")
@export var LOOK_CLAMP = 60
@export var LOOK_SMOOTHING = 0.2
@export var HORIZONTAL_SENSITIVITY_MOUSE = 0.5
@export var VERTICAL_SENSITIVITY_MOUSE = 0.5
@export var HORIZONTAL_SENSITIVITY_STICK = 2
@export var VERTICAL_SENSITIVITY_STICK = 2

var is_walking = false
var is_dashing = false
var is_aiming = false
var is_shooting = false
var is_attacking = false
var is_jumping = false
var is_picking_up = false
var is_pickup_collided = false
var is_double_jumping = false
var input_direction = Vector2.ZERO
var input_look = Vector2.ZERO

var new_rotation = Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const dash_duration = 1

func _ready():
	move_and_slide()

func _physics_process(delta):
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if collision.get_collider().collision_layer == 2:
			#print("I collided with ", collision.get_collider().collision_layer)
	compute_gravity(delta)
	compute_movement()

func _input(event):
	if event is InputEventMouseMotion:
		new_rotation.y += deg_to_rad(-event.relative.x) * HORIZONTAL_SENSITIVITY_MOUSE
		new_rotation.x += deg_to_rad(-event.relative.y) * VERTICAL_SENSITIVITY_MOUSE
		input_look.x = event.relative.x / 20

func _process(_delta):
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
	clear_frame_variables()

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
	is_picking_up = Input.is_action_just_pressed("pickup") and is_pickup_collided

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
			0.05
		)
	else:
		camera.global_transform.origin = camera_collider.global_transform.origin

func update_rotation_smoothing():
	rotation.y = lerp_angle(rotation.y, new_rotation.y, LOOK_SMOOTHING)
	camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x, new_rotation.x, LOOK_SMOOTHING)

func compute_look_stick():
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	look_dir = look_dir.normalized()
	input_look.x = look_dir.x * 0.6
	new_rotation.y += deg_to_rad(-look_dir.x) * HORIZONTAL_SENSITIVITY_STICK
	new_rotation.x += deg_to_rad(-look_dir.y) * VERTICAL_SENSITIVITY_STICK

func compute_movement():
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	var current_speed = speed
	if is_dashing and (!inventory_manager.has_jetpack or !inventory_manager.jetpack_has_fuel):
		current_speed = dashing_speed
	elif is_dashing and inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel:
		current_speed = jetpack_dashing_speed
	
	if direction.length():
		is_walking = true
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		is_walking = false
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func compute_gravity(delta):
	velocity.y -= weight * gravity * delta
	if is_on_floor():
		is_jumping = false

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			is_jumping = true
			velocity.y = jump_height
		elif inventory_manager.has_jetpack:
			is_double_jumping = true
			if inventory_manager.jetpack_has_fuel:
				velocity.y = jump_height

func clear_frame_variables():
	is_double_jumping = false

func set_camera_variables():
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
	animation_tree.equip = inventory_manager.equip_type
	animation_tree.direction = input_direction
	animation_tree.look = input_look
	animation_tree.is_dashing = is_dashing
	animation_tree.is_jumping = is_jumping
	animation_tree.is_aiming = is_aiming
	animation_tree.is_shooting = is_shooting
	animation_tree.is_attacking = is_attacking
	animation_tree.is_picking_up = is_picking_up
	animation_tree.is_on_floor = is_on_floor()

func set_inventory_items_variables():
	if inventory_manager.body_instance:
		inventory_manager.body_instance.is_dashing = is_dashing
		inventory_manager.body_instance.is_double_jumping = is_double_jumping
	if inventory_manager.right_hand_instance:
		inventory_manager.right_hand_instance.is_attacking = animation_tree.is_current_node_attacking()
