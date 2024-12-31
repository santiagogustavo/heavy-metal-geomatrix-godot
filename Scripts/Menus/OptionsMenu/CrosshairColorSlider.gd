class_name CrosshairColorSlider
extends HBoxContainer

@onready var slider = $CustomSlider10/HSlider

@export_enum("R", "G", "B", "A") var color_channel: String

func _ready():
	slider.value_changed.connect(on_value_changed)
	match color_channel:
		"R":
			slider.value = GameplaySettingsManager.crosshair_color_r
		"G":
			slider.value = GameplaySettingsManager.crosshair_color_g
		"B":
			slider.value = GameplaySettingsManager.crosshair_color_b
		_:
			slider.value = GameplaySettingsManager.crosshair_color_a

func on_value_changed(value: float) -> void:
	match color_channel:
		"R":
			GameplaySettingsManager.set_crosshair_color_r(value)
		"G":
			GameplaySettingsManager.set_crosshair_color_g(value)
		"B":
			GameplaySettingsManager.set_crosshair_color_b(value)
		_:
			GameplaySettingsManager.set_crosshair_color_a(value)
