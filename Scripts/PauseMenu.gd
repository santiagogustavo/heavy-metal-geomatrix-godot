extends CanvasLayer
class_name PauseMenu

@onready var paused_label = $Control/MarginContainer/VBoxContainer/HBoxContainer/Paused
@onready var bg = $Control/BG

func update_paused_label():
	if GameManager.is_game_paused:
		paused_label.text = "Paused"
		bg.show()
	else:
		paused_label.text = ""
		bg.hide()

func _process(delta):
	update_paused_label()
