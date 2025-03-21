extends Node3D

@export var item_name: String
@export var splash: Texture2D

@onready var name_label: Label = $TitleViewport/Control/Label
@onready var splash_rect: TextureRect = $SplashViewport/Control/Control/Splash

var item_instance: Node3D

func _ready() -> void:
	name_label.text = item_name
	splash_rect.texture = splash
