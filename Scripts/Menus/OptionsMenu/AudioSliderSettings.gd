extends HBoxContainer
class_name AudioSliderSettings

@onready var name_label = $AudioNameLabel as Label
@onready var slider = $CustomSlider10/HSlider as HSlider

@export_enum("Master", "UI", "Music", "Effects") var bus_name: String

var bus_index: int = 0

func _ready():
	slider.value_changed.connect(on_value_changed)
	get_bus_index_from_name()
	set_name_label_text()
	set_slider_value()

func set_name_label_text() -> void:
	name_label.text = str(bus_name) + " Volume"

func set_slider_value() -> void:
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func get_bus_index_from_name() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)

func on_value_changed(value: float) -> void:
	AudioSettingsManager.set_volume_index(bus_index, value)
