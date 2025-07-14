extends MarginContainer

@onready var value_label: Label = $Value

func _process(_delta: float) -> void:
	value_label.text = str(Engine.get_frames_per_second())
