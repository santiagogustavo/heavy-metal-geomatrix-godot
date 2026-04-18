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

@export var min_scale: float = 1
@export var max_scale: float = 1

func _ready() -> void:
	var random_scale = randf_range(min_scale, max_scale)
	scale = Vector3(random_scale, random_scale, random_scale)
	match rotation_axis:
		RotationAxis.x:
			rotation_degrees.x = randi_range(min_rotation, max_rotation)
		RotationAxis.y:
			rotation_degrees.y = randi_range(min_rotation, max_rotation)
		RotationAxis.z:
			rotation_degrees.z = randi_range(min_rotation, max_rotation)
	if !VideoSettingsManager.permanent_decals:
		get_tree().create_timer(VideoSettingsManager.decal_lifetime).timeout.connect(queue_free)
