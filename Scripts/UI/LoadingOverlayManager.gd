extends CanvasLayer

@onready var animation_tree: AnimationTree = $Control/AnimationTree
@onready var current_screen: TextureRect = $Control/CurrentScreen

static var is_loading: bool = false

func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/is_saving", is_loading)
	animation_tree.set("parameters/conditions/saved", !is_loading)

func get_current_screen_texture() -> void:
	var new_screen_texture: ImageTexture = ImageTexture.new()
	new_screen_texture.set_image(get_viewport().get_texture().get_image())
	current_screen.texture = new_screen_texture
