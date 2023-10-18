extends Node3D
class_name LevelConfig

@export_subgroup("Properties")
@export var level_name: String

@export_subgroup("Environment")
@export var is_rainy: bool

func _ready():
	GameManager.current_level_config = self
