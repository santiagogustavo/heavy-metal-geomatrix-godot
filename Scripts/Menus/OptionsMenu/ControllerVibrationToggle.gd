extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = InputSettingsManager.vibration_enabled
	button.toggled.connect(on_toggle_vibration)

func on_toggle_vibration(toggled_on: bool) -> void:
	sfx.play()
	InputSettingsManager.set_vibration_enabled(toggled_on)
	if toggled_on:
		InputManager.vibrate_controller(0, 1, 1, 0.2)
