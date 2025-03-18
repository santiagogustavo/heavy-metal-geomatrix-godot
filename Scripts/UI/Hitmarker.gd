extends Node3D
class_name Hitmarker

@onready var critical: Sprite3D = $Critical
@onready var label: Label = $SubViewport/Control/Label

var damage_taken: int = 0
var is_critical: = false

func _ready() -> void:
	critical.visible = is_critical
	label.text = str(damage_taken)
