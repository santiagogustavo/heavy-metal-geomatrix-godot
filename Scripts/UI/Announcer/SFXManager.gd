extends Node2D

@onready var round_announce: AudioStreamPlayer2D = $Rounds/Round
@onready var round_1: AudioStreamPlayer2D = $"Rounds/1"
@onready var round_2: AudioStreamPlayer2D = $"Rounds/2"
@onready var round_3: AudioStreamPlayer2D = $"Rounds/3"
@onready var round_4: AudioStreamPlayer2D = $"Rounds/4"
@onready var round_5: AudioStreamPlayer2D = $"Rounds/5"
@onready var round_6: AudioStreamPlayer2D = $"Rounds/6"
@onready var round_7: AudioStreamPlayer2D = $"Rounds/7"
@onready var round_8: AudioStreamPlayer2D = $"Rounds/8"
@onready var round_9: AudioStreamPlayer2D = $"Rounds/9"
@onready var round_final: AudioStreamPlayer2D = $Rounds/Final

func announce_round() -> void:
	if !GameManager.current_match:
		return
	if GameManager.current_match.is_final_round:
		round_final.play()
	else:
		round_announce.play()

func play_current_round() -> void:
	if !GameManager.current_match or GameManager.current_match.is_final_round:
		return
	match GameManager.current_match.current_round:
		1:
			round_1.play()
		2:
			round_2.play()
		3:
			round_3.play()
		4:
			round_4.play()
		5:
			round_5.play()
		6:
			round_6.play()
		7:
			round_7.play()
		8:
			round_8.play()
		9:
			round_9.play()
