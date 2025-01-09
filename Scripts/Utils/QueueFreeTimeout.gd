extends Node3D

@export var timeout: float

func _ready() -> void:
	get_tree().create_timer(timeout, false).connect('timeout', queue_free)
