extends TextureRect
class_name MugshotViewport

@export var character: Definitions.Characters

@onready var hound_mug: TextureRect = $SubViewport/Control/Hound
@onready var slash_mug: TextureRect = $SubViewport/Control/Slash
@onready var zeus_mug: TextureRect = $SubViewport/Control/Zeus
@onready var sarge_mug: TextureRect = $SubViewport/Control/Sarge
@onready var kassey_mug: TextureRect = $SubViewport/Control/Kassey
@onready var stab_mug: TextureRect = $SubViewport/Control/Stab
@onready var duke_mug: TextureRect = $SubViewport/Control/Duke
@onready var di_mug: TextureRect = $SubViewport/Control/Di
@onready var lance_mug: TextureRect = $SubViewport/Control/Lance
@onready var phantom_mug: TextureRect = $SubViewport/Control/Phantom
@onready var mayfly_mug: TextureRect = $SubViewport/Control/Mayfly
@onready var talbot_mug: TextureRect = $SubViewport/Control/Talbot

@onready var color_rect: ColorRect = $SubViewport/Control/ColorRect
@onready var headshot: ColorRect = $SubViewport/Control/Headshot

func _process(_delta: float) -> void:
	color_rect.visible = false
	headshot.visible = false
	clear_all_mugshots()
	match character:
		Definitions.Characters.Hound:
			hound_mug.visible = true
		Definitions.Characters.Slash:
			slash_mug.visible = true
		Definitions.Characters.Zeus:
			zeus_mug.visible = true
		Definitions.Characters.Sarge:
			sarge_mug.visible = true
		Definitions.Characters.Kassey:
			kassey_mug.visible = true
		Definitions.Characters.Stab:
			stab_mug.visible = true
		Definitions.Characters.Duke:
			duke_mug.visible = true
		Definitions.Characters.Di:
			di_mug.visible = true
		Definitions.Characters.Lance:
			lance_mug.visible = true
		Definitions.Characters.Phantom:
			phantom_mug.visible = true
		Definitions.Characters.Mayfly:
			mayfly_mug.visible = true
		Definitions.Characters.Talbot:
			talbot_mug.visible = true

func clear_all_mugshots() -> void:
	hound_mug.visible = false
	slash_mug.visible = false
	zeus_mug.visible = false
	sarge_mug.visible = false
	kassey_mug.visible = false
	stab_mug.visible = false
	duke_mug.visible = false
	di_mug.visible = false
	lance_mug.visible = false
	phantom_mug.visible = false
	mayfly_mug.visible = false
	talbot_mug.visible = false
	
