extends Control
class_name VersusArenaCard

@export var arena: Definitions.Arenas

@onready var splash: TextureRect = $Outline/BG/Splash
@onready var label: Label = $Outline/BG/Label

func _ready() -> void:
	var arena_controller: ArenaController = load(Definitions.ArenaScenes[arena]).instantiate()
	splash.texture = arena_controller.splash_small
	label.text = Definitions.ArenaNames[arena]
