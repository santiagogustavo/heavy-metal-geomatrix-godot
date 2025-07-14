extends Node3D

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _process(_delta: float) -> void:
	if GameManager.get_player_one() and GameManager.current_match:
		visible = (
			GameManager.get_player_one().is_locked_on
			and !GameManager.current_match.is_player_input_locked
		)
	(mesh.get_active_material(0) as StandardMaterial3D).albedo_color = Color(
		GameplaySettingsManager.crosshair_color_r,
		GameplaySettingsManager.crosshair_color_g,
		GameplaySettingsManager.crosshair_color_b,
		GameplaySettingsManager.crosshair_color_a,
	)
