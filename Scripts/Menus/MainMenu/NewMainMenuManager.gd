extends Control
class_name MainMenuManager

signal open
signal close
signal finished

@export var options: Array[Button] = []
@export var cursor_sfx: AudioStreamPlayer
@export var select1_sfx: AudioStreamPlayer
@export var select2_sfx: AudioStreamPlayer
@export var description_label: Label

@onready var options_menu: OptionsMenuManager = $OptionsMenuLayer/OptionsMenu
@onready var root_animation_tree: AnimationTree = $AnimationTree
@onready var options_animation_tree: AnimationTree = $MainMenuLayer/OptionsContainer/AnimationTree

var is_open: bool = false
var selected: bool = false

func _ready() -> void:
	GameManager.unlock_cursor()
	GameManager.current_scene_type = Definitions.SceneType.MainMenu
	open.connect(open_menu)
	close.connect(close_menu)
	options_menu.close.connect(focus_first_option)
	for option: Button in options:
		option.connect("focus_entered", func ():
			cursor_sfx.play()
			description_label.text = option.description
			InputManager.vibrate_controller(0, 1.0, 0, 0.1)
		)
		option.connect("button_down", func ():
			if selected:
				return
			selected = option.close_on_select
			if selected:
				select1_sfx.play()
				InputManager.vibrate_controller(0, 1.0, 1.0, 0.3)
				connect("finished", option.on_menu_selected)
			else:
				select2_sfx.play()
				InputManager.vibrate_controller(0, 1.0, 0.0, 0.3)
				option.on_menu_selected()
		)
		option.connect("mouse_entered", func (): option.grab_focus())

func _process(_delta: float) -> void:
	var can_process_input = !DebugMenuManager.is_menu_open and !OptionsMenuManager.is_menu_open and !selected
	set_process_input(can_process_input)
	root_animation_tree.set("parameters/conditions/selected", selected)
	options_animation_tree.set("parameters/conditions/is_open", is_open)
	options_animation_tree.set("parameters/conditions/is_closed", !is_open)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_start") and !is_open:
		open.emit()
	elif event.is_action_pressed("ui_cancel") and is_open:
		close.emit()

func focus_first_option():
	for option: Button in options:
		option.release_focus()
	options[0].grab_focus()

func open_menu() -> void:
	is_open = true
	InputManager.vibrate_controller(0, 0, 1, 0.2)

func close_menu() -> void:
	is_open = false
	(root_animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback).travel("Glitch", true)

func emit_finished():
	finished.emit()
