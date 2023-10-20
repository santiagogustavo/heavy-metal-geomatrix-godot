extends Node3D

@export var timeout: float

func _ready():
	await get_tree().create_timer(timeout, false).timeout
	queue_free()
