extends CanvasLayer
class_name PauseMenu

@onready var control = $Control
@onready var buttons = $Control/Panel/Buttons
@onready var options_button = $Control/Panel/Buttons/Options

@onready var options_menu = $OptionsMenu as OptionsMenu

func _ready():
	exit_options_menu()
	connect_options_signals()
	var index = 0
	for child in buttons.get_children():
		if index == 0:
			child.grab_focus()
			_on_focus_entered(child)
		else:
			_on_focus_exited(child)
		child.connect("button_down", child._on_button_down)
		child.connect("focus_entered", func(): _on_focus_entered(child))
		child.connect("focus_exited", func(): _on_focus_exited(child))
		child.connect("mouse_entered", func(): _on_mouse_entered(child))
		index += 1

func _process(_delta):
	update_show_hide()

func _on_mouse_entered(button):
	button.grab_focus()
	_on_focus_entered(button)

func _on_focus_entered(button):
	button.modulate = Color(Color.WHITE, 1)
	
func _on_focus_exited(button):
	button.modulate = Color(Color.WHITE, 0.5)

func connect_options_signals() -> void:
	options_button.button_down.connect(open_options_menu)
	options_menu.exit.connect(exit_options_menu)

func open_options_menu() -> void:
	options_menu.visible = true
	options_menu.set_process(true)

func exit_options_menu() -> void:
	options_menu.visible = false
	options_menu.set_process(false)

func update_show_hide():
	if GameManager.is_game_paused:
		control.show()
	else:
		control.hide()
		exit_options_menu()
