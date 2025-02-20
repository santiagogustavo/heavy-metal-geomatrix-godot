extends CanvasLayer

@onready var animation_tree: AnimationTree = $Control/AnimationTree

static var is_saving: bool = false

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/is_saving", is_saving)
	animation_tree.set("parameters/conditions/saved", !is_saving)
