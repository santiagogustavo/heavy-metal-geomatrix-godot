extends HBoxContainer

@onready var button: CheckButton = $Button
@onready var sfx: AudioStreamPlayer2D = $SFX

func _ready() -> void:
	button.button_pressed = GameplaySettingsManager.hud_sway_enabled
	button.toggled.connect(on_toggle_hitmarkers)

func on_toggle_hitmarkers(toggled_on: bool) -> void:
	sfx.play()
	GameplaySettingsManager.set_hud_sway_enabled(toggled_on)
