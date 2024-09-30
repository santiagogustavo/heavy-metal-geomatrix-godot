extends Node3D	

@export var effect_enabled = false
@export var minimum_camera_rotation = 15

@onready var current_camera = get_viewport().get_camera_3d()
@onready var particles_1 = $Control/Particles1
@onready var particles_2 = $Control/Particles2

func _process(_delta: float) -> void:
	var is_emitting = current_camera.global_rotation_degrees.x >= minimum_camera_rotation and effect_enabled
	particles_1.emitting = is_emitting
	particles_2.emitting = is_emitting
