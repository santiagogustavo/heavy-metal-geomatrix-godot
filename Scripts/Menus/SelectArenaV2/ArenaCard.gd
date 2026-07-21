extends Button
class_name ArenaCardV2

signal selected

@export_category("Properties")
@export var arena_splash: Texture2D
@export var arena_name: String
@export var selecting_player: int = 1

@onready var splash: TextureRect = $CardOutline/SplashMask/Splash
@onready var name_label: Label = $CardOutline/SplashMask/Splash/ArenaName/Label
@onready var animation_tree: AnimationTree = $AnimationTree

var hovered: bool = false

func _ready() -> void:
	splash.texture = arena_splash
	name_label.text = arena_name
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

func update_animation_tree() -> void:
	animation_tree.set("parameters/conditions/hovered_p1", hovered and selecting_player == 1)
	animation_tree.set("parameters/P1/conditions/unhovered_p1", !hovered and selecting_player == 1)
