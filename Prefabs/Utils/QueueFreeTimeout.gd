extends Node3D

@export var timeout: float
@export var timeout_light: float

@onready var light: OmniLight3D = $OmniLight3D

func _ready():
	if light:
		get_tree().create_timer(timeout_light, false).connect('timeout', light.queue_free)
	get_tree().create_timer(timeout, false).connect('timeout', queue_free)
