extends SubViewport

func _process(_delta: float) -> void:
	size = DisplayServer.window_get_size()
	scaling_3d_scale = VideoSettingsManager.rendering_scale
