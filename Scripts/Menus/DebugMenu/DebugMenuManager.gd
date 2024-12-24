extends CanvasLayer
class_name DebugMenuManager

# Stats overlay
@onready var stats_overlay: Container = $StatsOverlay

# Text display and input
@onready var console_container: Container = $Container
@onready var messages: RichTextLabel = $Container/Console/Messages
@onready var line_edit: LineEdit = $Container/Console/Input

# SFX
@onready var sfx_close: AudioStreamPlayer2D = $SFX/Close
@onready var sfx_confirm: AudioStreamPlayer2D = $SFX/Confirm
@onready var sfx_error: AudioStreamPlayer2D = $SFX/Error
@onready var sfx_open: AudioStreamPlayer2D = $SFX/Open
@onready var sfx_warning: AudioStreamPlayer2D = $SFX/Warning

# Internals
@onready var commands: DebugCommands = DebugCommands.new()
var expression: Expression = Expression.new()

# Constants
var MAX_CARET_COLUMN = 100000

var history: Array[String] = []
var history_index: int = -1

static var is_menu_open: bool = false

func _ready() -> void:
	commands._get_autocomplete_info()
	commands.connect("clear_console", on_clear)
	console_container.visible = is_menu_open

func _process(_delta: float) -> void:
	stats_overlay.visible = commands.is_stats_overlay_open
	
	var toggle: bool = Input.is_action_just_pressed("dev_console_toggle")
	if toggle:
		toggle_menu()
		return
	if !is_menu_open:
		return
	var close: bool = Input.is_action_just_pressed("ui_cancel")
	var enter: bool = Input.is_action_just_pressed("dev_console_enter")
	var prev: bool = Input.is_action_just_pressed("dev_console_prev")
	var next: bool = Input.is_action_just_pressed("dev_console_next")
	var autocomplete: bool = Input.is_action_just_pressed("dev_console_autocomplete")
	
	if close:
		toggle_menu()
	elif enter:
		on_submit()
	elif autocomplete:
		on_autocomplete()
	elif prev or next:
		on_navigate(prev)

func on_submit() -> void:
	history.push_front(line_edit.text)
	run_command(line_edit.text)
	history_index = -1
	line_edit.text = ''
	
func on_clear() -> void:
	history = []
	messages.clear()

func on_autocomplete() -> void:
	line_edit.text = commands._get_autocomplete_match(line_edit.text)
	line_edit.caret_column = MAX_CARET_COLUMN

func on_navigate(prev: bool) -> void:
	if history.size() == 0:
		return
	if prev:
		history_index -= 1
	else:
		history_index += 1
	history_index = clamp(history_index, 0, history.size() - 1)
	line_edit.text = history[history_index]
	line_edit.caret_column = MAX_CARET_COLUMN

func run_command(command: String) -> void:
	messages.append_text("[b]> " + command + "[/b]\n")
	var error: Error = expression.parse(command)
	if error != OK:
		print_error(expression.get_error_text())
	else:
		var result = expression.execute([], commands)
		if not expression.has_execute_failed():
			if result:
				print_success(result)
			else:
				sfx_confirm.play()
		else:
			print_error(expression.get_error_text())
	messages.append_text("\n")

func print_success(message = '') -> void:
	sfx_confirm.play()
	messages.append_text("[color=green]OK! [/color]" + str(message))

func print_warning(message = '') -> void:
	sfx_warning.play()
	messages.append_text("[color=yellow]Warning! [/color]" + str(message))

func print_error(message = '') -> void:
	sfx_error.play()
	messages.append_text("[color=red]Error! [/color]" + str(message))

func toggle_menu() -> void:
	is_menu_open = !is_menu_open
	console_container.visible = is_menu_open
	if is_menu_open:
		sfx_open.play()
		line_edit.grab_focus()
		line_edit.text = ''
	else:
		sfx_close.play()
