extends Camera3D


@export var aim_fov_change = -15 
@export var dash_fov_change = 10
@onready var camera_effects = $CameraEffects3D
@onready var motion_blur = $CameraEffects3D/MotionBlur

var has_jetpack = false
var is_dashing = false
var is_aiming = false

var original_fov

func _ready():
	original_fov = fov
	load_level_configs()

func _process(_delta):
	update_fov()
	update_motion_blur()

func load_level_configs():
	camera_effects.get_node("CameraRain").effect_enabled = GameManager.current_level_config.is_rainy
	
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
