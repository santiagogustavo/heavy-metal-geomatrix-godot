extends RigidBody3D

@export_subgroup("Properties")
@export var speed: float = 50.0
@export var damage: int = 5

@export_subgroup("Instances")
@export var generic_decal: PackedScene
@export var glass_decal: PackedScene
@export var water_decal: PackedScene
@export var stone_decal: PackedScene
@export var dirt_decal: PackedScene
@export var blood_decal: PackedScene

func _physics_process(delta: float):
	var collision: KinematicCollision3D = move_and_collide(transform.basis * Vector3(0, 0, -1) * speed * delta)
	if collision:
		collide(collision)

func instantiate_decal(collider: CollisionObject3D, point: Vector3, normal: Vector3, type: int):
	var decal_instance: Node3D
	if type == Definitions.SurfaceType.Hitbox:
		decal_instance = blood_decal.instantiate()
	elif type == Definitions.SurfaceType.Glass:
		decal_instance = glass_decal.instantiate()
	elif type == Definitions.SurfaceType.Water:
		decal_instance = water_decal.instantiate()
	elif type == Definitions.SurfaceType.Stone:
		decal_instance = stone_decal.instantiate()
	elif type == Definitions.SurfaceType.Dirt:
		decal_instance = dirt_decal.instantiate()
	else:
		decal_instance = generic_decal.instantiate()
	collider.add_child(decal_instance)
	decal_instance.global_transform.origin = point
	decal_instance.look_at(point + normal + Vector3(0.001, 0.0, 0.0))

func collide(collision: KinematicCollision3D):
	var collider: CollisionObject3D = collision.get_collider()
	# if collider is world boundary
	if collider.collision_layer == Definitions.SurfaceType.Hitbox:
		(collider as CharacterHitbox).damage_taken(damage, collision.get_position())
	if collider.collision_layer == Definitions.SurfaceType.WorldBoundary:
		queue_free()
	else:
		var point: Vector3 = collision.get_position()
		var normal: Vector3 = collision.get_normal()
		instantiate_decal(collider, point, normal, collider.collision_layer)
		queue_free()
