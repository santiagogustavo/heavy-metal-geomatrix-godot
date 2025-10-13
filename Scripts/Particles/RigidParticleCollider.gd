extends RigidBody3D
class_name RigidParticleCollider

var local_collision_pos: Vector3
var local_collision_normal: Vector3

func _ready() -> void:
	body_entered.connect(func (_body: PhysicsBody3D): queue_free())

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if state.get_contact_count() >= 1:
		local_collision_pos = state.get_contact_local_position(0)
		local_collision_normal = state.get_contact_local_normal(0)
