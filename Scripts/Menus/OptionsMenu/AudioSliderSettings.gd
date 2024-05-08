class_name AudioSliderSettings
extends Control

@onready var name_label = $HBoxContainer/AudioNameLabel as Label
@onready var slider = $HBoxContainer/HSlider as HSlider
@onready var num_label = $HBoxContainer/AudioNumLabel as Label

@export_enum("Master", "UI", "Music", "Effects") var bus_name: String

var bus_index: int = 0

func _ready():
	slider.value_changed.connect(on_value_changed)
	get_bus_index_from_name()
	set_name_label_text()
	set_slider_value()

func set_name_label_text() -> void:
	name_label.text = str(bus_name) + " Volume"

func set_num_label_text() -> void:
	num_label.text = str(slider.value * 10)

func set_slider_value() -> void:
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_num_label_text()

func get_bus_index_from_name() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

func on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	SettingsManager.audio_volumes[bus_name] = value
	set_num_label_text()
