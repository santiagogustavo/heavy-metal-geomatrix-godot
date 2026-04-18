extends WorldEnvironment

@onready var world_compositor: Compositor = load("res://Prefabs/Levels/WorldEnvironmentCompositor.tres")

func _ready() -> void:
	compositor = world_compositor

func _process(_delta: float) -> void:
	for effect in compositor.compositor_effects:
		if effect is GuertinMotionBlur:
			effect.enabled = (
				VideoSettingsManager.motion_blur_enabled and
				GameManager.current_match.is_ongoing
			)
			effect.intensity = VideoSettingsManager.motion_blur_intensity
