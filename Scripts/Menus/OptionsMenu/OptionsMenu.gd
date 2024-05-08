class_name OptionsMenu
extends Control

signal exit

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton as Button

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)

func on_exit_pressed() -> void:
	SettingsManager.save_audio_settings()
	SettingsManager.save_settings_file()
	exit.emit()
	set_process(false)
