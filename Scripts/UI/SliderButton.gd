extends Label
class_name SliderButton

var is_focused = false

func _input(event):
	if is_focused and event.is_action_pressed("ui_accept"):
		_on_button_pressed()

func _on_button_pressed():
	pass
