extends Node3D
class_name LevelConfig

@export_subgroup("Properties")
@export var level_name: String = ""

@export_subgroup("Environment")
@export var is_rainy: bool = false
@export var is_snowy: bool = false

func _ready():
	GameManager.lock_cursor()
	GameManager.current_level_config = self
	if !GameManager.current_match:
		GameManager.create_match(MatchManager.new())
