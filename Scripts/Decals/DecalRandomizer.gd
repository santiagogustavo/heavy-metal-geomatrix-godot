extends Decal

enum RotationAxis {
	x,
	y,
	z
}

@export_subgroup("Transform")
@export var min_rotation: int = 0
@export var max_rotation: int = 0
@export var rotation_axis: RotationAxis = RotationAxis.y
@export var position_range: float = 0.0

@export_subgroup("Flags")
@export var randomize_position: bool = false

@export var min_scale: float = 1
@export var max_scale: float = 1

func _ready() -> void:
	randomize_decal()
	if !VideoSettingsManager.permanent_decals:
		get_tree().create_timer(VideoSettingsManager.decal_lifetime).timeout.connect(queue_free)

func randomize_decal() -> void:
	if randomize_position:
		var random_x = randf_range(-position_range, position_range)
		var random_z = randf_range(-position_range, position_range)
		position.x += random_x
		position.z += random_z
	var random_scale = randf_range(min_scale, max_scale)
	scale = Vector3(random_scale, random_scale, random_scale)
	var random_rotation = deg_to_rad(randi_range(min_rotation, max_rotation))
	match rotation_axis:
		RotationAxis.x:
			rotate_x(random_rotation)
		RotationAxis.y:
			rotate_y(random_rotation)
		RotationAxis.z:
			rotate_z(random_rotation)
