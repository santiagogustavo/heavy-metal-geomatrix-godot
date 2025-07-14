extends Control
class_name OptionsMenuManager

signal close

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var close_sfx: AudioStreamPlayer2D = $SFX/Close
@onready var tab_bar: TabBar = $SettingsTabContainer/TabBar

var has_played_animation: bool = false
var has_closed_menu: bool = true

static var is_menu_open: bool = false

func _process(_delta: float) -> void:
	visible = is_menu_open
	set_process_input(!DebugMenuManager.is_menu_open and is_menu_open)
	if !visible:
		has_played_animation = false
		if !has_closed_menu:
			has_closed_menu = true
			close_sfx.play()
	else:
		has_closed_menu = false
		if !has_played_animation:
			has_played_animation = true
			tab_bar.grab_focus()
			animation_player.play("Open")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_menu()

func open_menu() -> void:
	is_menu_open = true

func close_menu() -> void:
	SettingsManager.save_settings()
	is_menu_open = false
	close.emit()
