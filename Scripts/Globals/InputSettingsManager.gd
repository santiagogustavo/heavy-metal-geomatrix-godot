extends Node

var look_smoothing_enabled: bool = false
var look_smoothing_intensity: float = 0.2

var mouse_horizontal_sensitivity: float = 0.15
var mouse_vertical_sensitivity: float = 0.15

var stick_horizontal_sensitivity: float = 1.25
var stick_vertical_sensitivity: float = 1.25

func set_look_smoothing_enabled(value: bool) -> void:
	look_smoothing_enabled = value

func set_look_smoothing_intensity(value: float) -> void:
	look_smoothing_intensity = value
	
func set_mouse_horizontal_sensitivity(value: float) -> void:
	mouse_horizontal_sensitivity = value

func set_mouse_vertical_sensitivity(value: float) -> void:
	mouse_vertical_sensitivity = value

func set_stick_horizontal_sensitivity(value: float) -> void:
	stick_horizontal_sensitivity = value

func set_stick_vertical_sensitivity(value: float) -> void:
	stick_vertical_sensitivity = value
