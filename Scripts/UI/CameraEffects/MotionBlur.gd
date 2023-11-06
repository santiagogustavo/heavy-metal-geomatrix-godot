extends Node3D

@onready var material = $MeshInstance3D.mesh.material
@onready var original_blur_power = material.get("shader_parameter/blur_power")

var has_jetpack = false
var is_dashing = false

func _ready():
	material.set("shader_parameter/blur_power", 0.0)

func _process(_delta):
	var current_power = original_blur_power
	
	if is_dashing and has_jetpack:
		current_power += 0.01
	elif !is_dashing:
		current_power = 0.0
	
	var material_power = material.get("shader_parameter/blur_power")
	material.set("shader_parameter/blur_power", lerp(material_power, current_power, 0.1))
