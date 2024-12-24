extends Node
class_name MatchManager

@export_subgroup("Round Settings")
@export_range(1, 5) var rounds: int = 2
@export_range(30, 99) var time: int = 60

@onready var current_round: int = 0
@onready var current_time: int = 0

# Definitions
enum RoundStatus {
	Idle,
	Started,
	Ended,
}

# Internals
var timer: Timer = Timer.new()
var round_status: RoundStatus = RoundStatus.Idle

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer.connect("timeout", end_round)

func _ready() -> void:
	GameManager.current_scene_type = Definitions.SceneType.MatchStarted
	get_tree().root.add_child.call_deferred(timer)

func _process(_delta: float) -> void:
	current_time = ceili(timer.time_left)
	set_process_unhandled_input(!DebugMenuManager.is_menu_open)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.pause_game()

# Round management
func start_round() -> bool:
	if round_status == RoundStatus.Started:
		return false
	current_round += 1
	round_status = RoundStatus.Started
	timer.start(time)
	return true

func end_round() -> bool:
	if round_status != RoundStatus.Started:
		return false
	timer.stop()
	round_status = RoundStatus.Ended
	return true
