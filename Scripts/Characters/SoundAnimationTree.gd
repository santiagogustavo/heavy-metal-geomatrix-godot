extends AnimationTree

@export var is_walking = false
@export var is_jumping = false
@export var is_dashing = false
@export var is_picking_up = false
@export var is_on_floor = false

func _process(_delta):
	set("parameters/conditions/is_walking", is_walking)
	set("parameters/conditions/is_jumping", is_jumping)
	set("parameters/conditions/is_picking_up", is_picking_up)
	set("parameters/conditions/is_dashing", is_dashing)
	set("parameters/conditions/is_on_floor", is_on_floor)
