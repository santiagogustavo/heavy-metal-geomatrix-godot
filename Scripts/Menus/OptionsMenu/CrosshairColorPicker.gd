extends Control

@onready var button: ColorPickerButton = $HBoxContainer/Button

func _ready():
	button.color = Color(
		GameplaySettingsManager.crosshair_color_r,
		GameplaySettingsManager.crosshair_color_g,
		GameplaySettingsManager.crosshair_color_b,
		GameplaySettingsManager.crosshair_color_a,
	)
	button.color_changed.connect(on_button_color_changed)

func on_button_color_changed(value: Color) -> void:
	GameplaySettingsManager.set_crosshair_color(value)
