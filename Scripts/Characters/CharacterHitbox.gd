extends StaticBody3D
class_name CharacterHitbox

signal hit

@export var damage_factor: float = 1.0
var player_rid: RID

func damage_taken(damage: float, hit_position: Vector3) -> void:
	hit.emit(damage, damage_factor, hit_position)
