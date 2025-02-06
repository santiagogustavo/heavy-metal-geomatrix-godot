extends Button
class_name AvatarCard

@export_category("Properties")
@export var character: Definitions.Characters

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var avatar: TextureRect = $Avatar

@onready var select_screen_player: PackedScene = load(Definitions.Selects[character])
@onready var select: CharacterController = select_screen_player.instantiate()

func _ready() -> void:
	avatar.texture = select.avatar_big
	select.visible = false
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
		(select.animation_tree as TauntAnimationTree).play_entrance()
	)
