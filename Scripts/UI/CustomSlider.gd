extends TextureRect
class_name CustomSlider

@export_subgroup("Properties")
@export var enable_off_indicator: bool = false

@onready var slider: HSlider = $HSlider
@onready var off_indicator: ColorRect = $OffIndicator

func _process(_delta: float) -> void:
	if !enable_off_indicator:
		return
	off_indicator.visible = slider.value == slider.min_value
