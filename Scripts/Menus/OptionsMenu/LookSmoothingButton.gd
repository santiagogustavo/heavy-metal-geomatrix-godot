extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = InputSettingsManager.look_smoothing_enabled
	button.toggled.connect(on_toggle_smoothing)

func on_toggle_smoothing(toggled_on: bool) -> void:
	sfx.play()
	InputSettingsManager.set_look_smoothing_enabled(toggled_on)
