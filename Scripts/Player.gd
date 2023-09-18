extends CharacterBody3D

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera

@export var speed = 7.5
@export var dashing_speed = 10
@export var jetpack_dashing_speed = 12.5
@export var jump_height = 10
@export var weight = 2.5

var dash_duration = 1

@export var HORIZONTAL_SENSITIVITY_MOUSE = 0.5
@export var VERTICAL_SENSITIVITY_MOUSE = 0.5
@export var HORIZONTAL_SENSITIVITY_STICK = 1
@export var VERTICAL_SENSITIVITY_STICK = 1

var is_walking = false
var is_dashing = false
var is_aiming = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
		
func dash_stop():
	is_dashing = false
	
func update_dash():
	if !is_walking:
		is_dashing = false
		return
	
	if Input.is_action_just_pressed("dash") and is_walking and is_on_floor():
		is_dashing = true
		get_tree().create_timer(dash_duration).timeout.connect(dash_stop)

func update_aim():
	is_aiming = Input.is_action_pressed("aim")

func compute_look_stick():
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	look_dir = look_dir.normalized()
	
	rotate_y(deg_to_rad(-look_dir.x) * HORIZONTAL_SENSITIVITY_STICK)
	camera_pivot.rotate_x(deg_to_rad(-look_dir.y) * VERTICAL_SENSITIVITY_STICK)

func compute_movement():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = speed
	if is_dashing:
		current_speed = dashing_speed
	
	if direction:
		is_walking = true
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		is_walking = false
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

func compute_gravity(delta):
	if not is_on_floor():
		velocity.y -= weight * gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_height

func set_camera_variables():
	camera.is_dashing = is_dashing
	camera.is_aiming = is_aiming

func _physics_process(delta):
	compute_look_stick()
	compute_gravity(delta)
	compute_movement()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * HORIZONTAL_SENSITIVITY_MOUSE)
		camera_pivot.rotate_x(deg_to_rad(-event.relative.y) * VERTICAL_SENSITIVITY_MOUSE)

func _process(delta):
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60));
	update_dash()
	update_aim()
	set_camera_variables()
	move_and_slide()	
