extends Camera3D


@export var aim_fov_change = -15 
@export var dash_fov_change = 10

@onready var camera_effects = $CameraEffects3D
@onready var motion_blur = $CameraEffects3D/MotionBlur
@onready var camera_collider: RayCast3D = $'../CameraCollider'

var has_jetpack = false
var is_dashing = false
var is_aiming = false

var original_fov

func _ready():
	original_fov = fov
	load_level_configs()

func _process(delta: float):
	load_settings()
	update_fov()
	update_motion_blur()
	update_camera_collision(delta)

func load_settings():
	original_fov = GameplaySettingsManager.fov

func load_level_configs():
	camera_effects.get_node("CameraRain").effect_enabled = GameManager.current_level_config.is_rainy
	camera_effects.get_node("CameraRain2d").effect_enabled = GameManager.current_level_config.is_rainy
	camera_effects.get_node("CameraSnow").effect_enabled = GameManager.current_level_config.is_snowy
	
func update_motion_blur():
	motion_blur.is_dashing = is_dashing
	motion_blur.has_jetpack = has_jetpack
	
func update_fov():
	var current_fov = original_fov
	
	if is_aiming:
		current_fov += aim_fov_change
	elif is_dashing:
		current_fov += dash_fov_change
	
	fov = lerp(fov, current_fov, 0.1)

func update_camera_collision(delta: float):
	if camera_collider.is_colliding():
		global_transform.origin = lerp(
			global_transform.origin,
			camera_collider.get_collision_point(),
			10 * delta
		)
	else:
		global_transform.origin = camera_collider.global_transform.origin
