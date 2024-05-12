class_name CategorySeparator
extends MarginContainer

@export var label_text: String
@onready var label = $VBoxContainer/Label as Label

func _ready():
	label.text = label_text
