extends CanvasLayer
class_name PauseMenuManager

@export var panel_buttons: Array[Button]

@onready var control: Control = $Control
@onready var panel: Control = $Control/Panel
@onready var panel_animator: AnimationPlayer = $Control/Panel/AnimationPlayer
@onready var options_menu: OptionsMenuManager = $OptionsMenu

# SFX
@onready var open: AudioStreamPlayer2D = $SFX/Open
@onready var close: AudioStreamPlayer2D = $SFX/Close
@onready var entered: AudioStreamPlayer2D = $SFX/Entered
@onready var selected: AudioStreamPlayer2D = $SFX/Selected

static var is_menu_open: bool = false

func _ready():
	panel.scale = Vector2(1, 0)
	close_menu(false)
	bind_options_menu()
	bind_buttons_sfx()
	GameManager.connect("pause", open_menu)
	GameManager.connect("resume", close_menu)

func _process(_delta: float) -> void:
	set_process_unhandled_input(!DebugMenuManager.is_menu_open and !OptionsMenuManager.is_menu_open and is_menu_open)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.resume_game()

func bind_options_menu():
	options_menu.connect("close", focus_first_button)

func bind_buttons_sfx():
	for button: Button in panel_buttons:
		button.connect("mouse_entered", play_entered_sfx)
		button.connect("focus_entered", play_entered_sfx)
		button.connect("button_down", play_selected_sfx)

func focus_first_button() -> void:
	panel_buttons[0].grab_focus()

func open_menu(play_sfx: bool = true):
	if play_sfx:
		open.play()
	set_process_unhandled_input(true)
	is_menu_open = true
	control.show()
	focus_first_button()
	panel_animator.play("Open")

func close_menu(play_sfx: bool = true):
	if play_sfx:
		close.play()
	set_process_unhandled_input(false)
	is_menu_open = false
	control.hide()

func play_entered_sfx():
	entered.play()

func play_selected_sfx():
	selected.play()
