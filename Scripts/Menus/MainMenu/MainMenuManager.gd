extends Control

@export var options: Array[TextureButton] = []
@export var cursor_sfx: AudioStreamPlayer
@export var select1_sfx: AudioStreamPlayer
@export var select2_sfx: AudioStreamPlayer
@export var description_label: Label
@onready var animation_player = $AnimationPlayer

@onready var exit2 = $OptionsContainer/OptionsList/Exit2

var selected_option_index = -1
var selected_option_name = ''
var selected_option_description = ''
var selected_with_close = false

var is_menu_open = false
var selected = false

func _ready():
	GameManager.unlock_cursor()
	GameManager.current_scene_type = Definitions.SceneType.Menu
	animation_player.current_animation = 'Idle'
	
	var index = 0
	for option in options:
		option.connect("button_down", func(): _on_button_down(option))
		option.connect("focus_entered", func(): _on_focus_entered(option, index))
		option.connect("mouse_entered", func(): _on_mouse_entered(option, index))
		index += 1

func _process(_delta):
	if Input.is_action_just_pressed("ui_start") and !is_menu_open:
		is_menu_open = true
		animation_player.current_animation = "PressedStart"
		select_first_option()
	elif Input.is_action_just_pressed("ui_cancel") and is_menu_open:
		is_menu_open = false
		animation_player.current_animation = "Idle"
	elif is_menu_open:
		update_description_label()
		update_options_slide()

func update_options_slide():
	var index = 0;
	for option in options:
		if index == selected_option_index:
			option.position.x = lerp(option.position.x, 0.0, 0.3)
		else:
			option.position.x = lerp(option.position.x, -40.0, 0.3)
		index += 1

func select_first_option():
	options[0].grab_focus()

func _on_button_down(option):
	play_selected_sfx(option)
	if selected_with_close:
		animation_player.current_animation = "Close"
	option._on_button_down()

func _on_mouse_entered(option, index):
	option.grab_focus()
	_on_focus_entered(option, index)

func _on_focus_entered(option, index):
	select_option(option, index)

func select_option(option, index):
	cursor_sfx.play()
	selected_option_index = index
	selected_option_name = option.name
	selected_option_description = option.description
	selected_with_close = option.close_on_select

func update_description_label():
	description_label.text = selected_option_description

func play_selected_sfx(option):
	if option.close_on_select:
		select1_sfx.play()
	else:
		select2_sfx.play()
