extends GPUParticles3D

@export var rigid_body: RigidParticleCollider
@export var floor_decals: Array[Decal]
@export var wall_decals: Array[Decal]

var local_collision_pos: Vector3

func _ready() -> void:
	rigid_body.reparent(get_tree().root)
	var global_velocity = rigid_body.linear_velocity
	var local_velocity = rigid_body.transform.basis.inverse() * global_velocity
	rigid_body.linear_velocity = local_velocity
	rigid_body.body_entered.connect(
		func (_body: PhysicsBody3D):
			var is_wall = abs(rigid_body.local_collision_normal.dot(Vector3.UP)) < 0.1
			if is_wall:
				instantiate_wall_decal()
			else:
				instantiate_floor_decal()
			queue_free()
	)

func instantiate_decal(decal: Decal) -> void:
	decal.reparent(get_tree().root)
	decal.global_transform.origin = rigid_body.local_collision_pos
	decal.look_at(
		rigid_body.local_collision_pos
		+ rigid_body.local_collision_normal
		+ Vector3(0.001, 0.0, 0.0)
	)
	decal.rotation_degrees.x += 90
	decal.visible = true

func instantiate_wall_decal() -> void:
	var wall_decal_instance: Decal = wall_decals.pick_random()
	instantiate_decal(wall_decal_instance)

func instantiate_floor_decal() -> void:
	var floor_decal_instance: Decal = floor_decals.pick_random()
	instantiate_decal(floor_decal_instance)
