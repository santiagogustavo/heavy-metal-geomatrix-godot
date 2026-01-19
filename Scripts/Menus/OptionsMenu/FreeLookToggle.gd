extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = GameplaySettingsManager.free_look_enabled
	button.toggled.connect(on_toggle_free_look)

func on_toggle_free_look(toggled_on: bool) -> void:
	sfx.play()
	GameplaySettingsManager.set_free_look_enabled(toggled_on)
