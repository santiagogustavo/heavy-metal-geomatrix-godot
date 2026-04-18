extends RigidBody3D
class_name FistController

@export var damage: int = 10
@export var hit_decal: PackedScene

var is_attacking: bool = false
var can_hit: bool = false
var player_rid: RID

var physics_state: PhysicsDirectBodyState3D

func _ready() -> void:
	body_entered.connect(handle_body_entered)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	physics_state = state

func handle_combo_animation_changed() -> void:
	can_hit = true

func compute_can_damage_hit(body: Node) -> bool:
	return (
		body != null
		and (body is CharacterHitbox)
		and (body as CharacterHitbox).player_rid != player_rid
		and is_attacking
		and can_hit
	)

func get_enemy_collider_idx(body: Node) -> int:
	var collider_idx: int = -1
	for collision in physics_state.get_contact_count():
		if physics_state.get_contact_collider(collision) == (body as CharacterHitbox).get_rid():
			collider_idx = collision
	return collider_idx

func handle_body_entered(body: Node):
	if !compute_can_damage_hit(body):
		return
	var collider_idx: int = get_enemy_collider_idx(body)
	if collider_idx == -1:
		return
	can_hit = false
	var point: Vector3 = physics_state.get_contact_local_position(collider_idx)
	var normal: Vector3 = physics_state.get_contact_local_normal(collider_idx)
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
