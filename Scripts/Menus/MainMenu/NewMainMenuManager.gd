extends Control
class_name MainMenuManager

signal finished

@export var options: Array[Button] = []
@export var cursor_sfx: AudioStreamPlayer
@export var select1_sfx: AudioStreamPlayer
@export var select2_sfx: AudioStreamPlayer
@export var description_label: Label

@onready var root_animation_tree: AnimationTree = $AnimationTree
@onready var options_animation_tree: AnimationTree = $MainMenuLayer/OptionsContainer/AnimationTree

var is_open: bool = false
var selected: bool = false
var has_focused_first_item: bool = false

func _ready() -> void:
	GameManager.unlock_cursor()
	GameManager.current_scene_type = Definitions.SceneType.MainMenu
	for option: Button in options:
		option.connect("focus_entered", func ():
			cursor_sfx.play()
			description_label.text = option.description
		)
		option.connect("button_down", func ():
			selected = option.close_on_select
			if selected:
				select1_sfx.play()
				connect("finished", option.on_menu_selected)
			else:
				select2_sfx.play()
				option.on_menu_selected()
		)
		option.connect("mouse_entered", func (): option.grab_focus())

func _process(_delta: float) -> void:
	set_process_input(!DebugMenuManager.is_menu_open and !OptionsMenuManager.is_menu_open)
	root_animation_tree.set("parameters/conditions/selected", selected)
	options_animation_tree.set("parameters/conditions/is_open", is_open)
	options_animation_tree.set("parameters/conditions/is_closed", !is_open)
	
	if OptionsMenuManager.is_menu_open:
		has_focused_first_item = false

	if is_open and !has_focused_first_item and !options[0].has_focus() and !OptionsMenuManager.is_menu_open:
		options[0].grab_focus()
		has_focused_first_item = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_start") and !is_open:
		is_open = true
	elif event.is_action_pressed("ui_cancel") and is_open:
		is_open = false
		has_focused_first_item = false
		(root_animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback).travel("Glitch", true)

func emit_finished():
	finished.emit()
