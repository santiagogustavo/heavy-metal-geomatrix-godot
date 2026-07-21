extends TextureRect
class_name TeamIcon

@export var team: Definitions.Teams

@onready var icon_323: Texture2D = load("res://Textures/Icons/Teams/323agents.png")
@onready var icon_707: Texture2D = load("res://Textures/Icons/Teams/707metalheads.png")
@onready var icon_818: Texture2D = load("res://Textures/Icons/Teams/818stompers.png")
@onready var icon_911: Texture2D = load("res://Textures/Icons/Teams/911elite.png")

func _process(_delta: float) -> void:
	match team:
		Definitions.Teams.Agents:
			texture = icon_323
		Definitions.Teams.Metalheads:
			texture = icon_707
		Definitions.Teams.Stompers:
			texture = icon_818
		Definitions.Teams.Elite:
			texture = icon_911
