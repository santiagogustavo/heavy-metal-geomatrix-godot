extends Node3D

@onready var control: Control = $Control
@onready var rect: ColorRect = $Control/ColorRect
@onready var animation_tree: AnimationTree = $Control/AnimationTree
@onready var material: Material = rect.material

func _process(_delta: float) -> void:
	if GameManager.current_level_config:
		control.visible = GameManager.current_level_config.is_sunny
	animation_tree.set("parameters/conditions/visible", Sun.is_sun_visible)
	animation_tree.set("parameters/conditions/hidden", !Sun.is_sun_visible)
	material.set("shader_parameter/sun_position", Sun.unprojected_sun_direction)
