extends Camera3D

@export var aim_fov_change = -15 
@export var dash_fov_change = 10
@onready var camera_effects = $CameraEffects3D

var is_dashing = false
var is_aiming = false
var original_fov

func _ready():
	original_fov = fov
	load_level_configs()

func _process(_delta):
	var current_fov = original_fov
	
	if is_aiming:
		current_fov += aim_fov_change
	elif is_dashing:
		current_fov += dash_fov_change
	
	fov = lerp(fov, current_fov, 0.1)

func load_level_configs():
	camera_effects.get_node("CameraRain").visible = GameManager.current_level_config.is_rainy
