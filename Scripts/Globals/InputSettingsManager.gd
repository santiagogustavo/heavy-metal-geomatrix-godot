extends Node

var aim_assist_enabled: bool = true

var look_smoothing_enabled: bool = false
var look_smoothing_intensity: float = 0.2

var mouse_horizontal_sensitivity: float = 0.15
var mouse_vertical_sensitivity: float = 0.15

var vibration_enabled: bool = true
var stick_horizontal_sensitivity: float = 1.25
var stick_vertical_sensitivity: float = 1.25

func set_aim_assist_enabled(value: bool) -> void:
	aim_assist_enabled = value

func set_look_smoothing_enabled(value: bool) -> void:
	look_smoothing_enabled = value

func set_look_smoothing_intensity(value: float) -> void:
	look_smoothing_intensity = value
	
func set_mouse_horizontal_sensitivity(value: float) -> void:
	mouse_horizontal_sensitivity = value

func set_mouse_vertical_sensitivity(value: float) -> void:
	mouse_vertical_sensitivity = value

func set_vibration_enabled(value: bool) -> void:
	vibration_enabled = value

func set_stick_horizontal_sensitivity(value: float) -> void:
	stick_horizontal_sensitivity = value

func set_stick_vertical_sensitivity(value: float) -> void:
	stick_vertical_sensitivity = value
