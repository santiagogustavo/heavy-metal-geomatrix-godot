extends CanvasLayer
class_name AnnouncerManager

signal start

@onready var animation_tree: AnimationTree = $Control/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var rounds_manager: AnnouncerRoundsManager = $Control/Invert/Rounds

func announce_round() -> void:
	state_machine.travel("RoundStart", true)

func emit_start_signal() -> void:
	start.emit()

func end_round_ko() -> void:
	state_machine.travel("RoundEndKO", true)

func end_round_time_up() -> void:
	state_machine.travel("RoundEndTimeUp", true)
