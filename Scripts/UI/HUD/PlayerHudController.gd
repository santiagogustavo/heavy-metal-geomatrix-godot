extends CanvasLayer

func _process(_delta: float) -> void:
	var current_match: MatchManager = GameManager.current_match
	if !current_match:
		return
	#visible = current_match.round_status == MatchManager.RoundStatus.Started
