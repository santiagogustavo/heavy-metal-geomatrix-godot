class_name PlayerHUD
extends CanvasLayer

@export var visor_bulge: float = -0.075
@export var sway_factor: float = 5.0
@export var sway_speed: float = 10.0
@export var input_look: Vector2 = Vector2.ZERO

@onready var subviewport_container: SubViewportContainer = $SwayContainer
@onready var main_container: Control = $SwayContainer/SubViewport/Container/Control

func _process(delta: float) -> void:
	var current_match: MatchManager = GameManager.current_match
	if !current_match:
		return
	visible = !current_match.has_ended
	update_visor()
	update_sway(delta)

func update_visor() -> void:
	subviewport_container.material.set(
		"shader_parameter/bulge",
		visor_bulge if GameplaySettingsManager.hud_visor_effect_enabled else 0.0
	)

func update_sway(delta: float) -> void:
	if GameplaySettingsManager.hud_sway_enabled:
		var clamped_input_look = input_look.normalized().round()
		subviewport_container.position = lerp(
			subviewport_container.position,
			clamped_input_look * sway_factor,
			delta * sway_speed,
		)
	else:
		subviewport_container.position = Vector2.ZERO
