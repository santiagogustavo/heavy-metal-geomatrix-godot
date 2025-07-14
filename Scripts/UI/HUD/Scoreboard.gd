extends Control

@onready var time_label: Label = $Timer/Time
@onready var round_label: Label = $Timer/Round

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if (
		!GameManager.current_match
		or GameManager.current_match.round_status != MatchManager.RoundStatus.Started
	):
		visible = false
		return
	visible = true
	time_label.text = str(GameManager.current_match.current_time)
	round_label.text = "Round " + str(GameManager.current_match.current_round)
