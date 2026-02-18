class_name Bullet
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

var emissor_position: Vector3
var emissor_rid: RID

func _physics_process(delta: float):
	var collision: KinematicCollision3D = move_and_collide(transform.basis * Vector3(0, 0, -1) * speed * delta)
	if collision:
		collide(collision)

func instantiate_decal(collider: CollisionObject3D, point: Vector3, normal: Vector3, type: int):
	var decal_instance: Node3D
	if type == Definitions.SurfaceType.Hitbox and blood_decal:
		decal_instance = blood_decal.instantiate()
	elif type == Definitions.SurfaceType.Glass and glass_decal:
		decal_instance = glass_decal.instantiate()
	elif type == Definitions.SurfaceType.Water and water_decal:
		decal_instance = water_decal.instantiate()
	elif type == Definitions.SurfaceType.Stone and stone_decal:
		decal_instance = stone_decal.instantiate()
	elif type == Definitions.SurfaceType.Dirt and dirt_decal:
		decal_instance = dirt_decal.instantiate()
	else:
		decal_instance = generic_decal.instantiate()
	if "emissor_rid" in decal_instance:
		decal_instance.emissor_rid = emissor_rid
	collider.add_child(decal_instance)
	decal_instance.global_transform.origin = point
	TransformUtils.safe_look_at(decal_instance, point + normal)

func collide(collision: KinematicCollision3D):
	var collider: CollisionObject3D = collision.get_collider()
	
	if collider is RigidBody3D:
		var impulse = collision.get_normal() * speed / 10
		(collider as RigidBody3D).apply_central_impulse(impulse * -1)
	
	# if collider is world boundary
	if collider.collision_layer == Definitions.SurfaceType.Hitbox:
		(collider as CharacterHitbox).damage_taken(damage, collision.get_position(), emissor_position)
	if collider.collision_layer == Definitions.SurfaceType.WorldBoundary:
		queue_free()
	else:
		var point: Vector3 = collision.get_position()
		var normal: Vector3 = collision.get_normal()
		instantiate_decal(collider, point, normal, collider.collision_layer)
		queue_free()
