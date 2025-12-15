extends Node3D

@export var node_to_follow: Node3D

func _process(_delta: float) -> void:
	position = node_to_follow.position
	rotation = node_to_follow.rotation
