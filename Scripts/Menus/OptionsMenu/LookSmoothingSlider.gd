extends HBoxContainer

@onready var slider = $CustomSlider10/HSlider

func _ready():
	slider.value = InputSettingsManager.look_smoothing_intensity
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	InputSettingsManager.set_look_smoothing_intensity(value)
