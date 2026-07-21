extends Label
class_name LabelRandomizerEffect

@export var typing_time: float = 0.5
@export var start_with_random: bool = false

var initial_text: String = ""
var has_played: bool = false
var individual_key_time: float = 0.0
var current_index: int = 0

func _ready() -> void:
	play_effect()

func play_effect() -> void:
	set_initial_text(text)
	compute_individual_key_time()
	current_index = 0
	text = ""
	if start_with_random:
		generate_rubbish()
	type_current_index()

func set_initial_text(init_text: String) -> void:
	initial_text = init_text

func generate_rubbish() -> void:
	for index in initial_text:
		if index == '\n':
			text += index
		else:
			text += char(randi_range(32, 126))

func compute_individual_key_time() -> void:
	individual_key_time = typing_time / initial_text.length()

func type_current_index() -> void:
	if current_index >= initial_text.length():
		has_played = true
	else:
		if start_with_random:
			text[current_index] = initial_text[current_index]
		else:
			text += initial_text[current_index]
		current_index += 1
		get_tree().create_timer(individual_key_time).timeout.connect(type_current_index)
