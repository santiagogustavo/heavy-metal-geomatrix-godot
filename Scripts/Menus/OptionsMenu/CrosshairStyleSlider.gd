extends Control

@onready var slider = $HBoxContainer/HSlider

func _ready():
	slider.value = GameplaySettingsManager.crosshair_style
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: int) -> void:
	GameplaySettingsManager.set_crosshair_style(value)
