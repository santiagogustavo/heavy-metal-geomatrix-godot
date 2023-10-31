extends AnimationTree

var is_shooting = false
var is_bursting = false

func _process(_delta):
	set("parameters/conditions/is_shooting", is_shooting)
