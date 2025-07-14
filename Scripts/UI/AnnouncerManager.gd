extends CanvasLayer
class_name AnnouncerManager

signal start
signal ready_to_start

@onready var animation_tree: AnimationTree = $Control/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var rounds_manager: AnnouncerRoundsManager = $Control/Invert/Rounds

var win: bool = false
var win_excessive: bool = false
var lose: bool = false
var draw: bool = false

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/win", win)
	animation_tree.set("parameters/conditions/win_excessive", win_excessive)
	animation_tree.set("parameters/conditions/lose", lose)
	animation_tree.set("parameters/conditions/draw", draw)

func clear_animator_variables() -> void:
	win = false
	win_excessive = false
	lose = false
	draw = false

func announce_round() -> void:
	state_machine.travel("RoundStart", true)

func emit_start_signal() -> void:
	start.emit()
	switch_to_player_camera()

func emit_ready_to_start_signal() -> void:
	ready_to_start.emit()

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
