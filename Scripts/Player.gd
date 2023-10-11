extends CharacterBody3D

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera
@onready var animation_tree = $Mayfly/AnimationTree
@onready var sound_tree = $Mayfly/SoundAnimationTree
@onready var dash_particle = $Dash

@export var speed = 7.5
@export var dashing_speed = 10
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10
@export var weight = 2.5

var dash_duration = 1

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
var can_double_jump = false
var input_direction = Vector2.ZERO
var input_look = Vector2.ZERO

var new_rotation = Vector3.ZERO

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

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
	if is_dashing:
		current_speed = dashing_speed
	
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
		is_double_jumping = false
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			is_jumping = true
			velocity.y = jump_height
		elif !is_double_jumping and can_double_jump:
			is_double_jumping = true
			velocity.y = jump_height

func set_camera_variables():
	camera.is_dashing = is_dashing
	camera.is_aiming = is_aiming
	
func set_sound_variables():
	sound_tree.is_walking = is_walking
	sound_tree.is_jumping = is_jumping
	sound_tree.is_dashing = is_dashing
	sound_tree.is_picking_up = is_picking_up
	sound_tree.is_on_floor = is_on_floor()

func set_animator_variables():
	animation_tree.direction = input_direction
	animation_tree.look = input_look
	animation_tree.is_dashing = is_dashing
	animation_tree.is_jumping = is_jumping
	animation_tree.is_aiming = is_aiming
	animation_tree.is_shooting = is_shooting
	animation_tree.is_attacking = is_attacking
	animation_tree.is_picking_up = is_picking_up
	animation_tree.is_on_floor = is_on_floor()
