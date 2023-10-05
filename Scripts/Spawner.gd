extends Node3D

@export var node_path: String
@onready var target_node = load(node_path)

func _ready():
	await get_tree().create_timer(2).timeout
	var instance = target_node.instantiate()
	instance.position.x = 5
	add_child(instance)
