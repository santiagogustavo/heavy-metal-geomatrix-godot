extends Node3D	

@onready var current_camera = get_viewport().get_camera_3d()
@onready var particles = $GPUParticles3D

func _process(delta):
	particles.global_position = current_camera.global_position
	particles.global_rotation = current_camera.global_rotation
