extends CanvasLayer
class_name PauseMenu

@onready var control = $Control
@onready var buttons = $Control/Panel/Buttons

var current_focus

func _ready():
	current_focus = buttons.get_child(0).name
	
	var index = 0
	for child in buttons.get_children():
		index = index + 1
		child.connect("mouse_entered", func (): _on_mouse_entered(child.name));

func _process(_delta):
	if !GameManager.is_game_paused:
		current_focus = null
	
	update_show_hide()
	update_buttons_focus()

	
func _on_mouse_entered(child_name):
	current_focus = child_name

func update_buttons_focus():
	for child in buttons.get_children():
		if child.name == current_focus:
			child.is_focused = true
			child.modulate = Color(Color.WHITE, 1)
		else:
			child.is_focused = false
			child.modulate = Color(Color.WHITE, 0.5)

func update_show_hide():
	if GameManager.is_game_paused:
		control.show()
	else:
		control.hide()
