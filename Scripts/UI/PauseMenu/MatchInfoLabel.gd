extends Label

func _process(delta: float) -> void:
	if !GameManager.current_match:
		visible = false
		return
	visible = true
	text = (
		str(GameManager.current_match.rounds) + " Wins • "
		+ str(GameManager.current_match.time) + "s"
	)
