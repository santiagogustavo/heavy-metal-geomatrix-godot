extends Node3D

@export var speed = 50.0
@export var hit_particle: PackedScene
@export var hit_decal: PackedScene

@onready var mesh = $Mesh
@onready var raycast = $RayCast3D
@onready var sfx = $SFX

var has_collided = false

func _process(delta):
	if raycast.is_colliding() and !has_collided:
		has_collided = true
		collide()
	elif !has_collided:
		position += transform.basis * Vector3(0, 0, -speed) * delta

func instantiate_decal(point: Vector3, normal: Vector3):
	var decal_instance = hit_decal.instantiate()
	get_tree().root.add_child(decal_instance)
	
	decal_instance.global_transform.origin = point
	TransformUtils.safe_look_at(decal_instance, point + normal)

func instantiate_hit(point: Vector3, normal: Vector3):
	var hit_instance = hit_particle.instantiate()
	get_tree().root.add_child(hit_instance)
	
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)
	hit_instance.get_node("RaySpark").emitting = true

func collide():
	var collider = raycast.get_collider()
	
	# if collider is world boundary
	if collider.collision_layer == 16:
		queue_free()
	else:
		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		instantiate_hit(point, normal)
		instantiate_decal(point, normal)
		mesh.visible = false
		sfx.play()
		await get_tree().create_timer(1).timeout
		queue_free()
