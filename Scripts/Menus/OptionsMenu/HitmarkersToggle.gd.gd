extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = GameplaySettingsManager.hitmarkers_enabled
	button.toggled.connect(on_toggle_hitmarkers)

func on_toggle_hitmarkers(toggled_on: bool) -> void:
	sfx.play()
	GameplaySettingsManager.set_hitmarkers_enabled(toggled_on)
