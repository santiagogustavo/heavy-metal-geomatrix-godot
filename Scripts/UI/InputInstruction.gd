extends HBoxContainer
class_name InputInstruction

enum InputAction {
	UI_ACCEPT,
	UI_CANCEL,
	UI_UP,
	UI_DOWN,
	UI_LEFT,
	UI_RIGHT,
	UI_CHANGE_SKIN,
	UI_NEXT_TAB,
	UI_PREV_TAB,
}

const InputActionKeys: Dictionary = {
	InputAction.UI_ACCEPT: "ui_accept",
	InputAction.UI_CANCEL: "ui_cancel",
	InputAction.UI_UP: "ui_up",
	InputAction.UI_DOWN: "ui_down",
	InputAction.UI_LEFT: "ui_left",
	InputAction.UI_RIGHT: "ui_right",
	InputAction.UI_CHANGE_SKIN: "ui_change_skin",
	InputAction.UI_NEXT_TAB: "ui_next_tab",
	InputAction.UI_PREV_TAB: "ui_prev_tab"
}

@export var actions: Array[InputAction]
@export var custom_label_translation: String
@onready var label: Label = $Label

func _ready() -> void:
	for action in actions:
		add_input_icon_rect(action, 0)
		if custom_label_translation:
			label.text = tr(custom_label_translation)
		else:
			label.text = tr(InputActionKeys[action])
	move_child(label, get_child_count() - 1)

func add_input_icon_rect(action: InputAction, event_index: int = 0) -> InputIconTextureRect:
	var rect: InputIconTextureRect = InputIconTextureRect.new()
	rect.action_name = InputActionKeys[action]
	rect.event_index = event_index
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	rect.custom_minimum_size = Vector2(24, 24)
	add_child(rect)
	return rect
