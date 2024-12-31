extends Control

@onready var tab_bar: TabBar = $TabBar
@onready var tab_container: TabContainer = $TabContainer
@onready var hover_sfx: AudioStreamPlayer2D = $SFX/Entered
@onready var select_sfx: AudioStreamPlayer2D = $SFX/Selected

func _ready() -> void:
	tab_bar.grab_focus()
	tab_bar.connect("tab_hovered", func (_any): hover_sfx.play())
	tab_bar.connect("tab_selected", tab_selected)

func tab_selected(current_tab: int) -> void:
	select_sfx.play()
	tab_container.current_tab = current_tab
	
