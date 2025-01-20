extends DirectionalLight3D
class_name Sun

static var effective_sun_direction: Vector3 = Vector3.ZERO
static var unprojected_sun_direction: Vector2 = Vector2.ZERO
static var is_sun_visible: bool = false

func _process(_delta: float) -> void:
	if !GameManager.current_level_config or !GameManager.current_level_config.is_sunny:
		return
	var camera: Camera3D = get_viewport().get_camera_3d()
	effective_sun_direction = global_transform.basis.z * maxf(camera.near, 1.0)
	effective_sun_direction += camera.global_transform.origin
	is_sun_visible = not camera.is_position_behind(effective_sun_direction)
	if is_sun_visible:
		unprojected_sun_direction = camera.unproject_position(effective_sun_direction)
