extends Node3D
class_name SwordController

@export_subgroup("Properties")
@export var item_name: String

@export var hit_particle: PackedScene
@export var hit_sfx: PackedScene
@export var is_attacking = false
@export var health = 100.0

@onready var trail = $GPUTrail3D
@onready var raycast: RayCast3D = $StaticBody3D/RayCast3D

var has_collided = false

func _process(_delta):
	detect_raycast_collision()
	trail.set_process(is_attacking)
	trail.visible = is_attacking

func instantiate_sfx(point: Vector3):
	var sfx_instance = hit_sfx.instantiate()
	raycast.get_collider().add_child(sfx_instance)
	sfx_instance.global_transform.origin = point

func instantiate_hit(point: Vector3, normal: Vector3):
	var hit_instance = hit_particle.instantiate()
	get_tree().root.add_child(hit_instance)
	
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)
	hit_instance.emitting = true

func detect_raycast_collision():
	if is_attacking and raycast.is_colliding():
		var point = raycast.get_collision_point()
		var normal = raycast.get_collision_normal()
		
		if !has_collided:
			instantiate_sfx(point)
		
		instantiate_hit(point, normal)
		has_collided = true
	else:
		has_collided = false
