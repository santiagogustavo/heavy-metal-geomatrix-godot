extends Control

@export var options: Array[TextureRect] = []
@export var cursor_sfx: AudioStreamPlayer
@export var select1_sfx: AudioStreamPlayer
@export var select2_sfx: AudioStreamPlayer
@export var description_label: Label
@onready var animation_player = $AnimationPlayer

var selected_option = 0
var selected_option_name = ''
var selected_option_description = ''
var selected_with_close = false

var is_menu_open = false
var selected = false

func _ready():
	GameManager.unlock_cursor()
	GameManager.current_scene_type = Definitions.SceneType.Menu
	bind_mouse_over()
	animation_player.current_animation = 'Idle'

func _process(_delta):
	if Input.is_action_just_pressed("ui_start") and !is_menu_open:
		is_menu_open = true
		animation_player.current_animation = "PressedStart"
	elif is_menu_open:
		update_options()
		update_description_label()

func _input(event):
	if !is_menu_open:
		return
	
	if event.is_action_pressed("ui_accept"):
		play_selected_sfx()
		if selected_with_close:
			animation_player.current_animation = "Close"
	if event.is_action_pressed("ui_up"):
		if selected_option == 0:
			selected_option = options.size() - 1
		else:
			selected_option -= 1
	if event.is_action_pressed("ui_down"):
		if selected_option == options.size() - 1:
			selected_option = 0
		else:
			selected_option += 1

func bind_mouse_over():
	var index = 0
	for option in options:
		option.connect(
			"mouse_entered",
			func (): _on_mouse_entered(
				option.name,
				option.description,
				option.close_on_select,
				index
			)
		);
		index += 1

func update_options():
	var index = 0
	for option in options:
		if index == selected_option:
			option.is_focused = true
			option.position.x = lerp(option.position.x, 0.0, 0.3)
		else:
			option.is_focused = false
			option.position.x = lerp(option.position.x, -40.0, 0.3)
		index += 1

func update_description_label():
	description_label.text = selected_option_description

func play_selected_sfx():
	if selected_with_close:
		select1_sfx.play()
	else:
		select2_sfx.play()
	
func _on_mouse_entered(option_name: String, description: String, with_close: bool, index: int):
	cursor_sfx.play()
	selected_option = index
	selected_option_name = option_name
	selected_option_description = description
	selected_with_close = with_close
