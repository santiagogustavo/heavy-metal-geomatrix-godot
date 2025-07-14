extends Node3D

@onready var rect: ColorRect = $Control/ColorRect
@onready var material: ShaderMaterial = rect.material

func _process(_delta: float) -> void:
	set_effect_enabled(VideoSettingsManager.bloom_enabled)
	set_effect_intensity(VideoSettingsManager.bloom_intensity)

func set_effect_enabled(enabled: bool) -> void:
	rect.visible = enabled

func set_effect_intensity(amount: float) -> void:
	material.set("shader_parameter/visibility", amount)
