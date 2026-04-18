extends GunFireMode
class_name GunEnergyMode

@export_subgroup("Energy")
@export var spend_amount: float
@export var beam: Node3D
@export var raycasts: Array[RayCast3D] = []
@export var hit_decal: PackedScene
var energy: float = 100.0

const type: GunBulletMode.Type = GunBulletMode.Type.Energy
