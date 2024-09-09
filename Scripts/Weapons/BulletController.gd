extends Node3D

@export var speed: float = 50.0
@export var hit_particle: PackedScene
@export var hit_decal: PackedScene

@onready var mesh: MeshInstance3D = $RigidBody3D/Mesh
@onready var rigidBody = $RigidBody3D
@onready var sfx = $SFX


func _physics_process(delta: float):
	var collision: KinematicCollision3D = rigidBody.move_and_collide(transform.basis * Vector3(0, 0, -1) * speed * delta)
	if collision:
		collide(collision)

func instantiate_decal(point: Vector3, normal: Vector3):
	var decal_instance: Node3D = hit_decal.instantiate()
	get_tree().root.add_child(decal_instance)
	decal_instance.global_transform.origin = point
	decal_instance.global_transform = TransformUtils.look_at_with_y(decal_instance.global_transform, normal, Vector3.UP)

func instantiate_hit(point: Vector3, normal: Vector3):
	var hit_instance: Node3D = hit_particle.instantiate()
	get_tree().root.add_child(hit_instance)
	
	hit_instance.global_transform.origin = point
	hit_instance.global_transform = TransformUtils.look_at_with_y(hit_instance.global_transform, normal, Vector3.UP)
	hit_instance.get_node("RaySpark").emitting = true

func collide(collision: KinematicCollision3D):
	var collider: Object = collision.get_collider()
	# if collider is world boundary
	if collider.collision_layer == 16:
		queue_free()
	else:
		var point: Vector3 = collision.get_position()
		var normal: Vector3 = collision.get_normal()
		print_debug(normal)
		instantiate_hit(point, normal)
		instantiate_decal(point, normal)
		mesh.visible = false
		sfx.play()
		get_tree().create_timer(0.1).connect("timeout", queue_free)
