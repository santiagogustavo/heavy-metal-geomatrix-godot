extends Node
class_name TransformUtils

static func safe_look_at(node : Node3D, target : Vector3) -> void:
	var direction = (target - node.global_transform.origin).normalized()
	var up_vector = Vector3.UP
	
	if abs(direction.dot(up_vector)) < 0.999:
		node.look_at(target, up_vector)
	else:
		node.look_at(target + Vector3(0, 0, 0.001))
