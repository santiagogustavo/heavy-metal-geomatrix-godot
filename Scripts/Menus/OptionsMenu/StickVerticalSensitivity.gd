extends HBoxContainer

@onready var slider = $CustomSlider10/HSlider

func _ready():
	slider.value = InputSettingsManager.stick_vertical_sensitivity
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	InputSettingsManager.set_stick_vertical_sensitivity(value)
