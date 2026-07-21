extends Control
class_name TeamCard

@export var team: Definitions.Teams

@onready var label: Label = $Label

func _process(_delta: float) -> void:
	label.text = Definitions.TeamNames[team]
