extends Camera3D

@export var aim_fov_change = -15 
@export var dash_fov_change = 10

var is_dashing = false
var is_aiming = false
var original_fov

func _ready():
	original_fov = fov

func _process(delta):
	var current_fov = original_fov
	
	if is_aiming:
		current_fov += aim_fov_change
	elif is_dashing:
		current_fov += dash_fov_change
	
	fov = lerp(fov, current_fov, 0.1)
