extends Node

var fov: float = 60
var hitmarkers_enabled: bool = true

var crosshair_style: int = 2
var crosshair_scale: float = 0.5
var crosshair_color_r: float = 255
var crosshair_color_g: float = 0
var crosshair_color_b: float = 240
var crosshair_color_a: float = 255

func set_fov(value: float) -> void:
	fov = value

func set_hitmarkers_enabled(value: bool) -> void:
	hitmarkers_enabled = value

func set_crosshair_style(value: int) -> void:
	crosshair_style = value

func set_crosshair_scale(value: float) -> void:
	crosshair_scale = value

func set_crosshair_color_r(value: float) -> void:
	crosshair_color_r = value

func set_crosshair_color_g(value: float) -> void:
	crosshair_color_g = value

func set_crosshair_color_b(value: float) -> void:
	crosshair_color_b = value

func set_crosshair_color_a(value: float) -> void:
	crosshair_color_a = value
