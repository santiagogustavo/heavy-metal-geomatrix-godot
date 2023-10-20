extends Node3D	

@export var effect_enabled = false
@export var minimum_camera_rotation = 15

@onready var current_camera = get_viewport().get_camera_3d()
@onready var particle_drops = $"Rain Drops"
@onready var particle_drips = $"Rain Drips"

func _process(_delta):
	var is_emitting = current_camera.global_rotation_degrees.x >= minimum_camera_rotation and effect_enabled
	particle_drops.emitting = is_emitting
	particle_drips.emitting = is_emitting
