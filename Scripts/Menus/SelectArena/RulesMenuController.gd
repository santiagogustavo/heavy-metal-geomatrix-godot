extends CanvasLayer
class_name RulesMenuController

signal change_rounds
signal change_time

static var is_menu_open: bool = false

@onready var rules_rounds_options: OptionButton = $Control/VBoxContainer/RoundsSelect/OptionButton
@onready var rules_time_options: OptionButton = $Control/VBoxContainer/TimeSelect/OptionButton

static var instance: RulesMenuController

func _init() -> void:
	instance = self

func _ready() -> void:
	rules_rounds_options.item_selected.connect(func (index: int):
		var rounds: int = int(rules_rounds_options.get_item_text(index))
		change_rounds.emit(rounds)
	)
	rules_time_options.item_selected.connect(func (index: int):
		var time: int = int(rules_time_options.get_item_text(index))
		change_time.emit(time)
	)

func _process(_delta: float) -> void:
	visible = is_menu_open

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		is_menu_open = false

func focus_on_first() -> void:
	rules_rounds_options.grab_focus()
