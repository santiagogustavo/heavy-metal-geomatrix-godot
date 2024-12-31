extends Control

@onready var slider = $CustomSlider10/HSlider

func _ready():
	slider.value = GameplaySettingsManager.fov
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	GameplaySettingsManager.set_fov(value)
