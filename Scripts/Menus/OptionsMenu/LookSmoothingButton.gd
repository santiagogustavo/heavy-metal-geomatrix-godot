extends Control

@onready var button = $HBoxContainer/Button

func _ready():
	button.button_pressed = InputSettingsManager.look_smoothing_enabled
	button.toggled.connect(on_toggle_smoothing)

func on_toggle_smoothing(toggled_on: bool) -> void:
	InputSettingsManager.set_look_smoothing_enabled(toggled_on)
