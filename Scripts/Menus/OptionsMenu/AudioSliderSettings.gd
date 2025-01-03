extends HBoxContainer
class_name AudioSliderSettings

@onready var name_label: Label = $AudioNameLabel
@onready var custom_slider: CustomSlider = $CustomSlider10
@onready var slider: HSlider = $CustomSlider10/HSlider
@onready var focus_sfx: AudioStreamPlayer2D = $FocusSfx
@onready var change_sfx: AudioStreamPlayer2D = $ChangeSfx

@export_enum("Master", "UI", "Music", "Effects") var bus_name: String

var bus_index: int = 0

func _ready():
	slider.connect("focus_entered", func (): focus_sfx.play())
	slider.connect("value_changed", on_value_changed)
	custom_slider.enable_off_indicator = true
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
	if OptionsMenuManager.is_menu_open:
		change_sfx.play()
	AudioSettingsManager.set_volume_index(bus_index, value)
