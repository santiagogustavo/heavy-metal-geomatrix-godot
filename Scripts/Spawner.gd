extends Node3D

@export var pickup_to_spawn: PackedScene

func _ready():
	await get_tree().create_timer(2).timeout
	var instance = pickup_to_spawn.instantiate()
	instance.position.x = 5
	add_child(instance)
