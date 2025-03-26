extends Control
class_name Trophy

@export var is_win: bool = false
@export var is_excessive: bool = false

@onready var win = $Win
@onready var excessive = $Excessive

func _process(_delta: float) -> void:
	win.visible = is_win
	excessive.visible = is_excessive
