extends Control

@onready var slider = $HBoxContainer/HSlider

func _ready():
	slider.value = InputSettingsManager.stick_horizontal_sensitivity
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	InputSettingsManager.set_stick_horizontal_sensitivity(value)
