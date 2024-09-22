extends TextureRect

@export var sprites: Array[Texture2D]

func _process(_delta: float) -> void:
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
