extends Node
class_name GunFireMode

enum Type {
	Bullet,
	Energy
}

@export_subgroup("Properties")
@export var mode_name: String
@export var damage: int
@export_range(Definitions.WeaponRange.Min, Definitions.WeaponRange.Max, 0.1) var fire_range: float = Definitions.WeaponRange.Max
@export var zoom_factor: float = 1.0
