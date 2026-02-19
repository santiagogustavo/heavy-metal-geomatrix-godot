extends TextureRect

@export var sprites: Array[Texture2D]

func _process(_delta: float) -> void:
	var player_one: Player = GameManager.get_player_one()
	if player_one:
		visible = !player_one.is_locked_on
	modulate = Color(
		GameplaySettingsManager.crosshair_color_r,
		GameplaySettingsManager.crosshair_color_g,
		GameplaySettingsManager.crosshair_color_b,
		GameplaySettingsManager.crosshair_color_a,
	)
	scale = Vector2(
		GameplaySettingsManager.crosshair_scale,
		GameplaySettingsManager.crosshair_scale
	)
	texture = sprites[GameplaySettingsManager.crosshair_style]
