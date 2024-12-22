extends Control

@export var player_name: String
@export var avatar: Texture2D

@onready var label: Label = $Name
@onready var rect: TextureRect = $Avatar

func _ready() -> void:
	if player_name:
		label.text = player_name
	if avatar:
		rect.texture = avatar
