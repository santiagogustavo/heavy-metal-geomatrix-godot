extends CanvasLayer
class_name PauseMenu

@onready var control = $Control
#@onready var paused_label = $Control/MarginContainer/VBoxContainer/HBoxContainer/Paused
#@onready var bg = $Control/BG

func update_paused_label():
	if GameManager.is_game_paused:
		control.show()
	else:
		control.hide()

func _process(delta):
	update_paused_label()
