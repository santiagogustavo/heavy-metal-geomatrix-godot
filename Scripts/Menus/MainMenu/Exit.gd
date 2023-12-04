extends TextureButton

var description = 'Exit to desktop.'
var close_on_select = false

func _on_button_down():
	get_tree().quit()
