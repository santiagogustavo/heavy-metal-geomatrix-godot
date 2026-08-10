class_name PlayerHUD
extends CanvasLayer

@export var sway_factor: float = 4.0
@export var sway_speed: float = 30.0
@export var input_look: Vector2 = Vector2.ZERO

@onready var subviewport_container: SubViewportContainer = $SwayContainer
@onready var main_container: Control = $SwayContainer/SubViewport/Container/Control

func _process(delta: float) -> void:
	var current_match: MatchManager = GameManager.current_match
	if !current_match:
		return
	visible = !current_match.has_ended
	var clamped_input_look = input_look.normalized()
	subviewport_container.position = lerp(
		subviewport_container.position,
		clamped_input_look * sway_factor,
		delta * sway_speed,
	)
