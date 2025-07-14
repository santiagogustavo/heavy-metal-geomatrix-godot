extends HBoxContainer
class_name AnnouncerRoundsManager

@export_subgroup("References")
@export var numbers: Array[TextureRect]
@export var final: TextureRect

var current_round: int
var is_final: bool

func _process(_delta: float) -> void:
	final.visible = is_final
	var index: int = 1
	for number: TextureRect in numbers:
		number.visible = current_round == index and !is_final
		index += 1
