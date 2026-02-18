extends WorldEnvironment

func _process(_delta: float) -> void:
	for effect in compositor.compositor_effects:
		if effect is GuertinMotionBlur:
			effect.enabled = VideoSettingsManager.motion_blur_enabled
			effect.intensity = VideoSettingsManager.motion_blur_intensity
