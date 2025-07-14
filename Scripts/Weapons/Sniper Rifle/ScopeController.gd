extends CanvasLayer

@onready var parent_controller: GunController = get_parent()
@onready var scope: TextureRect = $Control/Scope
@onready var scope_outline: TextureRect = $Control/ScopeOutline
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var player_one: Player = GameManager.get_player_one()

func _ready() -> void:
	if !player_one or parent_controller.player_rid != player_one.get_rid():
		queue_free()

func _process(_delta: float) -> void:
	scope.self_modulate = Color(
		GameplaySettingsManager.crosshair_color_r,
		GameplaySettingsManager.crosshair_color_g,
		GameplaySettingsManager.crosshair_color_b,
		GameplaySettingsManager.crosshair_color_a,
	)
	scope_outline.self_modulate = Color(
		GameplaySettingsManager.crosshair_color_r,
		GameplaySettingsManager.crosshair_color_g,
		GameplaySettingsManager.crosshair_color_b,
		GameplaySettingsManager.crosshair_color_a,
	)
	scope_outline.pivot_offset = scope_outline.size / 2
	var is_aiming: bool = player_one.brain.is_aiming
	animation_tree.set("parameters/conditions/is_aiming", is_aiming)
	animation_tree.set("parameters/conditions/is_not_aiming", !is_aiming)
