extends Node3D
class_name SwordController

@export var hit_particle: PackedScene
@export var hit_sfx: PackedScene
@export var is_attacking = false
@export var current_animation: String
var last_animation: String

@onready var trail = $GPUTrail3D
@onready var raycast: RayCast3D = $StaticBody3D/RayCast3D

var has_collided = false

func _process(_delta):
	detect_raycast_collision()
	trail.set_process(is_attacking)
	trail.visible = is_attacking

func detect_raycast_collision():
	if is_attacking and raycast.is_colliding():
		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		var hit_instance = hit_particle.instantiate()
		
		if !has_collided:
			var sfx_instance = hit_sfx.instantiate()
			raycast.get_collider().add_child(sfx_instance)
			sfx_instance.global_transform.origin = point
		
		raycast.get_collider().add_child(hit_instance)
		hit_instance.global_transform.origin = point
		
		if normal == Vector3.UP:
			hit_instance.rotation_degrees.x = 90
		else:
			hit_instance.look_at(point + normal, Vector3.UP)
		hit_instance.emitting = true
		has_collided = true
	else:
		has_collided = false
