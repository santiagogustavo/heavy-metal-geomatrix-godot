extends Control

@onready var slider = $HBoxContainer/HSlider

func _ready():
	slider.value = InputSettingsManager.mouse_horizontal_sensitivity
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	InputSettingsManager.set_mouse_horizontal_sensitivity(value)
