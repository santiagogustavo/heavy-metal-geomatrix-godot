class_name CrosshairColorSlider
extends Control

@onready var name_label = $HBoxContainer/Label as Label
@onready var slider = $HBoxContainer/HSlider as HSlider
@onready var num_label = $HBoxContainer/NumLabel as Label

@export_enum("R", "G", "B", "A") var color_channel: String

func update_num_label(value: float):
	num_label.text = str(int(value * 255))

func _ready():
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 1.0 / 255.0
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
	name_label.text = "Crosshair " + color_channel
	update_num_label(slider.value)

func on_value_changed(value: float) -> void:
	update_num_label(slider.value)
	match color_channel:
		"R":
			GameplaySettingsManager.set_crosshair_color_r(value)
		"G":
			GameplaySettingsManager.set_crosshair_color_g(value)
		"B":
			GameplaySettingsManager.set_crosshair_color_b(value)
		_:
			GameplaySettingsManager.set_crosshair_color_a(value)
