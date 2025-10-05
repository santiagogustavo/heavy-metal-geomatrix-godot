extends MeshInstance3D

@export var face_surface: int

@export_subgroup("Eyes")
@export var blink_mask: Texture2D

var face_surface_material: StandardMaterial3D
var base_face_texture: Texture2D

func _ready() -> void:
	face_surface_material = get_surface_override_material(face_surface)
	base_face_texture = face_surface_material.albedo_texture
	blink_texture()

func blink_texture() -> void:
	var time_to_open: float = randf_range(0.1, 0.15)
	var time_to_next: float = randf_range(3.5, 4.0)
	face_surface_material.detail_albedo = blink_mask
	await get_tree().create_timer(time_to_open).timeout
	face_surface_material.detail_albedo = base_face_texture
	get_tree().create_timer(time_to_next).timeout.connect(blink_texture)
