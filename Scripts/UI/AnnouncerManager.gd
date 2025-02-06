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
	switch_to_player_camera()

func end_round_ko() -> void:
	state_machine.travel("RoundEndKO", true)

func end_round_time_up() -> void:
	state_machine.travel("RoundEndTimeUp", true)

func switch_to_ko_camera() -> void:
	Engine.time_scale = 0.35
	GameManager.get_player_one().ko_pivot.play_ko_animation()

func switch_to_round_camera() -> void:
	GameManager.get_player_one().round_pivot.play_announce_animation()

func switch_to_player_camera() -> void:
	Engine.time_scale = 1
	GameManager.get_player_one().switch_to_player_camera()
