extends Control
class_name OptionsMenuManager

@onready var exit_button: Button = $MarginContainer/VBoxContainer/ExitButton

static var is_menu_open: bool = false

func _init() -> void:
	visible = false

func _ready() -> void:
	exit_button.button_down.connect(quit_menu)

func _process(_delta: float) -> void:
	visible = is_menu_open
	if !visible:
		return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		quit_menu()

static func quit_menu() -> void:
	SettingsManager.save_settings()
	is_menu_open = false
