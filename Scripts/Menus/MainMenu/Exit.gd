extends TextureRectButton

var description = 'Exit to desktop.'
var close_on_select = false

func _on_button_pressed():
	get_tree().quit()
