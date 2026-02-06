extends AnimationTree
class_name GunAnimationTree

var is_shooting: bool = false
var is_bursting: bool = false
var selected_fire_mode: int = 0

func _process(_delta):
	set("parameters/conditions/is_shooting", is_shooting)
