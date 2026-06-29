extends Control

@onready var tab_bar: TabBar = $TabBar
@onready var tab_container: TabContainer = $TabContainer
@onready var hover_sfx: AudioStreamPlayer2D = $SFX/Entered
@onready var select_sfx: AudioStreamPlayer2D = $SFX/Selected

const SCROLL_VERTICAL_THRESHOLD = 100

func _ready() -> void:
	tab_bar.connect("tab_hovered", func (_any): hover_sfx.play())
	tab_bar.connect("tab_selected", tab_selected)
	tab_bar.current_tab = tab_container.current_tab

func _process(_delta: float) -> void:
	compute_tab_change_input()
	if Input.is_action_just_pressed("ui_up"):
		check_current_tab_scroll()

func tab_selected(current_tab: int) -> void:
	select_sfx.play()
	tab_container.current_tab = current_tab
	reset_tab_scroll(current_tab)

func compute_tab_change_input() -> void:
	if Input.is_action_just_pressed("ui_next_tab"):
		var next_tab = (
			0 if tab_container.current_tab + 1 > tab_container.get_tab_count() - 1
			else tab_container.current_tab + 1
		)
		tab_bar.current_tab = next_tab
		tab_bar.grab_focus()
	elif Input.is_action_just_pressed("ui_prev_tab"):
		var prev_tab = (
			0 if tab_container.current_tab - 1 < 0
			else tab_container.current_tab - 1
		)
		tab_bar.current_tab = prev_tab
		tab_bar.grab_focus()

func get_tab_scroll_container(tab: int) -> ScrollContainer:
	return tab_container.get_child(tab).get_node("ScrollContainer")

func check_current_tab_scroll() -> void:
	var scroll_container: ScrollContainer = get_tab_scroll_container(tab_container.current_tab)
	if scroll_container.scroll_vertical <= SCROLL_VERTICAL_THRESHOLD:
		reset_tab_scroll(tab_container.current_tab)

func reset_tab_scroll(tab: int) -> void:
	var scroll_container: ScrollContainer = get_tab_scroll_container(tab)
	scroll_container.scroll_vertical = 0
