extends HBoxContainer

@onready var slider = $CustomSlider10/HSlider

func _ready():
	slider.value = VideoSettingsManager.bloom_intensity
	slider.value_changed.connect(on_slider_value_changed)

func on_slider_value_changed(value: float) -> void:
	VideoSettingsManager.set_bloom_intensity(value)
