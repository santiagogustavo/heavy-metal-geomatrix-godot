class_name CategorySeparator
extends VBoxContainer

@export var label_text: String
@onready var label = $Label as Label

func _ready():
	label.text = label_text
