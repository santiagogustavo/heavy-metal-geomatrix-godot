extends CanvasLayer
class_name PauseMenu

@onready var control = $Control
@onready var buttons = $Control/Panel/Buttons

var current_focus = ''
var current_index = 0

func _ready():
	current_focus = buttons.get_child(0).name
	current_index = 0
	
	var index = 0
	for child in buttons.get_children():
		child.connect("mouse_entered", func (): _on_mouse_entered(child.name, index));
		index += 1		

func _input(event):
	if event.is_action_pressed("ui_up"):
		if current_index == 0:
			current_index = buttons.get_child_count() - 1
		else:
			current_index -= 1
	if event.is_action_pressed("ui_down"):
		if current_index == buttons.get_child_count() - 1:
			current_index = 0
		else:
			current_index += 1
	current_focus = buttons.get_child(current_index).name
	
func _process(_delta):
	if !GameManager.is_game_paused:
		current_focus = null
	
	update_show_hide()
	update_buttons_focus()
	
func _on_mouse_entered(child_name, child_index):
	current_focus = child_name
	current_index = child_index

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