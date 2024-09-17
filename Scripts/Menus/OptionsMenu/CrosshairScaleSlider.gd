extends Control

@onready var slider = $HBoxContainer/HSlider

func _ready():
	slider.value = GameplaySettingsManager.crosshair_scale
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	GameplaySettingsManager.set_crosshair_scale(value)
