@tool
extends RichTextEffect
class_name RichTextBioBold

var bbcode = "bb"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	char_fx.color = Color.YELLOW
	return true
