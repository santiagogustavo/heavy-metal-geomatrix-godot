extends Control

@onready var slider = $HBoxContainer/HSlider
@onready var label = $HBoxContainer/NumLabel

func _ready():
	slider.value = GameplaySettingsManager.fov
	slider.value_changed.connect(on_slider_value_changed)
	label.text = str(slider.value)

func on_slider_value_changed(value: float) -> void:
	GameplaySettingsManager.set_fov(value)
	label.text = str(value)
