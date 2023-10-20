extends AudioStreamPlayer

func _process(_delta):
	if GameManager.is_game_paused:
		volume_db = linear_to_db(0.3)
	else:
		volume_db = linear_to_db(1)
