class_name OptionsMenu
extends Control

signal exit

@onready var exit_button = $MarginContainer/VBoxContainer/ExitButton as Button

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		on_exit_pressed()

func on_exit_pressed() -> void:
	SettingsManager.save_settings()
	exit.emit()
	set_process(false)
