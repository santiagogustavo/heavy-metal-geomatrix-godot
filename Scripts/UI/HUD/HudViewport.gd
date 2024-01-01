extends SubViewport

var viewport_initial_size = Vector2()

func _ready():
	get_tree().root.connect('size_changed', _on_viewport_size_changed)
	viewport_initial_size = size

func _on_viewport_size_changed():
	#size = Vector2i(get_tree().root.size.x, get_tree().root.size.y)
	pass
