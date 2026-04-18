extends Node3D
class_name BrokenBody

var rigid_bodies: Array[RigidBody3D] = []

func _ready() -> void:
	for child in get_children():
		if child is RigidBody3D:
			rigid_bodies.append(child)

func unfreeze_rigid_body(body: RigidBody3D) -> void:
	body.set_deferred("freeze", false)

func start_rigid_bodies() -> void:
	for body in rigid_bodies:
		unfreeze_rigid_body(body)
