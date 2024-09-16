extends RigidBody3D

@export var speed: float = 50.0
@export var hit_particle: PackedScene
@export var hit_decal: PackedScene

func _physics_process(delta: float):
	var collision: KinematicCollision3D = move_and_collide(transform.basis * Vector3(0, 0, -1) * speed * delta)
	if collision:
		collide(collision)

func instantiate_decal(collider: CollisionObject3D, point: Vector3, normal: Vector3):
	var decal_instance: Node3D = hit_decal.instantiate()
	collider.add_child(decal_instance)
	decal_instance.global_transform.origin = point
	decal_instance.look_at(point + normal + Vector3(0.001, 0.0, 0.0))

func instantiate_hit(collider: CollisionObject3D, point: Vector3, normal: Vector3):
	var hit_instance: Node3D = hit_particle.instantiate()
	collider.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	hit_instance.look_at(point + normal + Vector3(0.001, 0.0, 0.0))
	hit_instance.get_node("RaySpark").emitting = true

func collide(collision: KinematicCollision3D):
	var collider: CollisionObject3D = collision.get_collider()
	# if collider is world boundary
	if collider.collision_layer == 16:
		queue_free()
	else:
		var point: Vector3 = collision.get_position()
		var normal: Vector3 = collision.get_normal()
		instantiate_decal(collider, point, normal)
		instantiate_hit(collider, point, normal)
		queue_free()
