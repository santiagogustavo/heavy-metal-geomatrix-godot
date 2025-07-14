extends Node3D

signal freed

@export var timeout: float

func _ready() -> void:
	get_tree().create_timer(timeout, false).timeout.connect(func (): 
		freed.emit()
		queue_free()
	)
