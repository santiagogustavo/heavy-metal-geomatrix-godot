extends Camera3D
class_name PlayerCamera

@export var aim_fov_change: int = -15 
@export var dash_fov_change: int = 10
@export var target_point: Vector3 = Vector3.ZERO

@onready var camera_effects = $CameraEffects3D
@onready var motion_blur = $CameraEffects3D/MotionBlur
@onready var camera_target_raycast = $'../TargetRaycast'
@onready var camera_collider: RayCast3D = $'../CameraCollider'
@onready var debug_collision_point: MeshInstance3D = $'../DebugCollisionPoint'

var has_jetpack: bool = false
var is_dashing: bool = false
var is_aiming: bool = false

var original_fov: float

func _ready() -> void:
	original_fov = fov
	load_level_configs()

func _process(delta: float) -> void:
	load_settings()
	update_fov()
	update_motion_blur()
	update_camera_collision(delta)
	update_camera_target()

func load_settings() -> void:
	original_fov = GameplaySettingsManager.fov
	debug_collision_point.visible = DebugCommands.target_point_visible

func load_level_configs():
	camera_effects.get_node("CameraRain2d").effect_enabled = GameManager.current_level_config.is_rainy
	camera_effects.get_node("CameraSnow").effect_enabled = GameManager.current_level_config.is_snowy
	
func update_motion_blur() -> void:
	motion_blur.is_dashing = is_dashing
	motion_blur.has_jetpack = has_jetpack
	
func update_fov() -> void:
	var current_fov = original_fov
	
	if is_aiming:
		current_fov += aim_fov_change
	elif is_dashing:
		current_fov += dash_fov_change
	
	fov = lerp(fov, current_fov, 0.1)

func update_camera_collision(delta: float) -> void:
	if camera_collider.is_colliding():
		global_transform.origin = lerp(
			global_transform.origin,
			camera_collider.get_collision_point(),
			10 * delta
		)
	else:
		global_transform.origin = camera_collider.global_transform.origin

func update_camera_target() -> void:
	if camera_target_raycast.is_colliding():
		var point = camera_target_raycast.get_collision_point()
		target_point = point
		debug_collision_point.global_position = target_point
