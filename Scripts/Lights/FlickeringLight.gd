extends OmniLight3D

@export var min_light_range = 0.01
@export var max_light_range = 0.3

func _process(_delta):
	light_energy = randf_range(min_light_range, max_light_range)
