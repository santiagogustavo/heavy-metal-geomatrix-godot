extends Button
class_name ArenaCard

@export_category("Properties")
@export var arena_card: PackedScene
@export_file var arena_scene: String

@onready var level_config: LevelConfig = arena_card.instantiate()
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var avatar: TextureRect = $Avatar

func _ready() -> void:
	avatar.texture = level_config.splash
	mouse_entered.connect(func (): grab_focus())
	focus_entered.connect(func ():
		InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)
		animation_tree.set("parameters/conditions/focus_entered", true)
		animation_tree.set("parameters/conditions/focus_exited", false)
	)
	focus_exited.connect(func ():
		animation_tree.set("parameters/conditions/focus_entered", false)
		animation_tree.set("parameters/conditions/focus_exited", true)
	)
	pressed.connect(func ():
		InputManager.vibrate_controller(0, 1.0, 1.0, 0.3)
	)
