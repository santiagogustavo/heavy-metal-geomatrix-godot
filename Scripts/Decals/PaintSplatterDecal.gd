extends Node3D

@export var decals: Array[Decal]
@export var color: Color
@export_range(0.0, 300.0) var lifetime: float = 300.0

var selected: Decal
var time_elapsed: float = 0.0

func _ready() -> void:
	selected = decals.pick_random()
	selected.modulate = color
	selected.visible = true

func _process(delta: float) -> void:
	if !selected:
		return
	if time_elapsed < lifetime:
		time_elapsed += delta
		var ratio = time_elapsed / lifetime
		selected.modulate.a = lerpf(selected.modulate.a, 0.0, ratio)
