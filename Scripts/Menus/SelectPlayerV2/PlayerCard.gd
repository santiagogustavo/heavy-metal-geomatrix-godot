extends Button
class_name PlayerCardV2

signal selected
signal change_skin

@export_category("Properties")
@export var character_portrait: Texture2D
@export var selecting_player: int = 1

@onready var portrait: TextureRect = $CardOutline/BG/PortraitSmall
@onready var animation_tree: AnimationTree = $AnimationTree

var hovered: bool = false

func _ready() -> void:
	portrait.texture = character_portrait
	mouse_entered.connect(func ():
		if focus_mode != FocusMode.FOCUS_NONE:
			grab_focus()
	)
	focus_entered.connect(func ():
		InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)
		hovered = true
	)
	focus_exited.connect(func ():
		hovered = false
	)
	pressed.connect(func ():
		InputManager.vibrate_controller(0, 1.0, 1.0, 0.3)
		animation_tree.set("parameters/P1/conditions/selected_p1", true)
		selected.emit()
	)

func _process(_delta: float) -> void:
	update_animation_tree()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_change_skin") and hovered:
		change_skin.emit()

func update_animation_tree() -> void:
	animation_tree.set("parameters/conditions/hovered_p1", hovered and selecting_player == 1)
	animation_tree.set("parameters/P1/conditions/unhovered_p1", !hovered and selecting_player == 1)
