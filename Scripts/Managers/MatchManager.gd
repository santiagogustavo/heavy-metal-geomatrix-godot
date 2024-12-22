extends Node

@export_subgroup("Round Settings")
@export_range(1, 5) var rounds: int = 2
@export_range(30, 99) var time: int = 60

@onready var current_round: int = 0
@onready var current_time: int = 0

# Internals
var timer: Timer
var round_has_started: bool
var round_has_ended: bool

func _process(delta: float) -> void:
	current_time = timer.time_left

# Round management
func start_round() -> void:
	current_round += 1
	timer.start(time)
	round_has_started = true
	round_has_ended = false

func end_round() -> void:
	timer.stop()
	round_has_started = false
	round_has_ended = true
