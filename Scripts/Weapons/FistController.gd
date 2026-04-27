extends ExtendedRigidBody3D
class_name FistController

@export var damage: int = 10
@export var hit_decal: PackedScene

func _ready() -> void:
	hit.connect(handle_hit)

func handle_combo_animation_changed() -> void:
	can_hit = true

func handle_hit(body: Node3D, point: Vector3, normal: Vector3):
	if "damage_taken" in body:
		(body as CharacterHitbox).damage_taken(
			damage,
			point,
			global_position,
			true,
			player_rid
		)
	instantiate_hit(point, normal)

func instantiate_hit(point: Vector3, normal: Vector3):
	var hit_instance = hit_decal.instantiate()
	get_tree().root.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)
