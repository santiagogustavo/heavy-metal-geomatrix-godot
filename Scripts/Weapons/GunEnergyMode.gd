extends GunFireMode
class_name GunEnergyMode

@export_subgroup("Energy")
@export var spend_amount: float
@export var beam: GPUParticles3D
@export var raycasts: Array[RayCast3D] = []
@export var hit_decal: PackedScene
@export var color: Color = Color(1.0, 1.0, 1.0)
@export var randomize_color: bool = false
var energy: float = 100.0

const type: GunBulletMode.Type = GunBulletMode.Type.Energy

func _ready() -> void:
	if randomize_color:
		color = Color(
			randf_range(0, 1),
			randf_range(0, 1),
			randf_range(0, 1),
		)
	if beam:
		beam.draw_pass_1.surface_get_material(0).set("albedo_color", color)
