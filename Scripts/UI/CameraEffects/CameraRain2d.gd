extends Node3D	

@export var effect_enabled = false
@export var minimum_camera_rotation = 15

@onready var current_camera = get_viewport().get_camera_3d()
@onready var particle_droplets_1: GPUParticles2D = $Control/Droplets1
@onready var particle_droplets_2: GPUParticles2D = $Control/Droplets2

func _process(_delta: float) -> void:
	var is_emitting = current_camera.global_rotation_degrees.x >= minimum_camera_rotation and effect_enabled
	particle_droplets_1.emitting = is_emitting
	particle_droplets_2.emitting = is_emitting
