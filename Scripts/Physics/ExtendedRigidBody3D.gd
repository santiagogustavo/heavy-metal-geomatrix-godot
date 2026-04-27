extends RigidBody3D
class_name ExtendedRigidBody3D

signal hit

var is_attacking: bool = false
var can_hit: bool = false
var player_rid: RID
var physics_state: PhysicsDirectBodyState3D

@onready var body_entered_listener: int = body_entered.connect(handle_body_entered)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	physics_state = state

func compute_can_damage_hit(body: Node) -> bool:
	var is_body_self_owned: bool = (
		body.player_rid == player_rid
		if "player_rid" in body
		else false
	)
	return (
		!is_body_self_owned
		and is_attacking
		and can_hit
	)

func get_collider_idx(body: Node) -> int:
	var collider_idx: int = -1
	for collision in physics_state.get_contact_count():
		if physics_state.get_contact_collider(collision) == body.get_rid():
			collider_idx = collision
	return collider_idx

func handle_body_entered(body: Node3D):
	if !compute_can_damage_hit(body):
		return
	var collider_idx: int = get_collider_idx(body)
	if collider_idx == -1:
		return
	can_hit = false
	var point: Vector3 = physics_state.get_contact_local_position(collider_idx)
	var normal: Vector3 = physics_state.get_contact_local_normal(collider_idx)
	hit.emit(body, point, normal)
