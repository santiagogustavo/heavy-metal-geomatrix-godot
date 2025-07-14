extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = InputSettingsManager.aim_assist_enabled
	button.toggled.connect(on_toggle_smoothing)

func on_toggle_smoothing(toggled_on: bool) -> void:
	sfx.play()
	InputSettingsManager.set_aim_assist_enabled(toggled_on)
