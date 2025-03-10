extends Node
class_name MatchManager

signal round_start
signal round_end
signal started
signal ended

@export_subgroup("Round Settings")
@export_range(1, 9) var rounds: int = 2
@export_range(30, 99) var time: int = 60

@onready var current_round: int = 0
@onready var current_time: int = 0

@onready var announcer: AnnouncerManager = preload("res://Scenes/UI/Announcer.tscn").instantiate()

# Definitions
enum RoundStatus {
	Idle,
	Started,
	Ended,
}

# Internals
var timer: Timer = Timer.new()
var round_status: RoundStatus = RoundStatus.Idle
var is_final_round: bool = false
var is_player_input_locked: bool = false

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer.connect("timeout", func (): end_round(true))

func _ready() -> void:
	GameManager.current_scene_type = Definitions.SceneType.MatchStarted
	get_tree().root.add_child.call_deferred(announcer)
	get_tree().root.add_child.call_deferred(timer)
	announcer.connect("start", start_round_logic)
	announcer.connect("ready_to_start", func(): 
		if is_final_round:
			finish_and_show_results()
		else:
			start_round()
	)
	started.emit()

func _process(_delta: float) -> void:
	current_time = ceili(timer.time_left)
	set_process_unhandled_input(!DebugMenuManager.is_menu_open and !PauseMenuManager.is_menu_open)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.pause_game()

func finish_and_show_results():
	var redirect_to_scene = "res://Scenes/MainMenu.tscn"
	SceneManager.load_scene_file(redirect_to_scene)

# Round management
func can_start_round() -> bool:
	return round_status != RoundStatus.Started

func can_end_round() -> bool:
	return round_status == RoundStatus.Started

func start_round() -> bool:
	if !can_start_round() or is_final_round:
		
		return false
	current_round += 1
	is_final_round = current_round == (rounds * 2) - 1
	is_player_input_locked = true
	round_start.emit()
	announcer.announce_round()
	announcer.rounds_manager.current_round = current_round
	announcer.rounds_manager.is_final = is_final_round
	return true

func start_round_logic() -> void:
	round_status = RoundStatus.Started
	is_player_input_locked = false
	timer.start(time)
	if time == 99:
		timer.paused = true

func end_round(timeout: bool = false) -> bool:
	if !can_end_round():
		return false
	if timeout:
		announcer.end_round_time_up()
	else:
		announcer.end_round_ko()
	round_end.emit()
	timer.stop()
	round_status = RoundStatus.Ended
	is_player_input_locked = true
	announcer.win = GameManager.is_player_one_win()
	announcer.win_excessive = GameManager.is_player_one_win_excessive()
	announcer.lose = GameManager.is_player_one_lose()
	announcer.draw = GameManager.is_match_a_draw()
	return true
