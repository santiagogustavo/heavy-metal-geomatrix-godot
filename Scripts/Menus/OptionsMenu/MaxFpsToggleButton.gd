extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = VideoSettingsManager.max_fps_enabled
	button.toggled.connect(on_toggle_button)

func on_toggle_button(toggled_on: bool) -> void:
	sfx.play()
	VideoSettingsManager.set_max_fps_enabled(toggled_on)
