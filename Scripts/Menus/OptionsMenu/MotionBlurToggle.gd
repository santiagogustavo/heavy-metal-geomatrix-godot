extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = VideoSettingsManager.motion_blur_enabled
	button.toggled.connect(on_toggle_button)

func on_toggle_button(toggled_on: bool) -> void:
	sfx.play()
	VideoSettingsManager.set_motion_blur_enabled(toggled_on)
