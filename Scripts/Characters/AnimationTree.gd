extends AnimationTree

var direction = Vector2.ZERO
var look = Vector2.ZERO

var is_dashing = false
var is_jumping = false
var is_on_floor = true
const lower_blend_tree_lerp = 15
const upper_blend_tree_lerp = 20

func _process(delta):
	update_lower_body(delta)
	update_upper_body(delta)

func update_lower_body(delta):
	# CONDITIONS #
	set("parameters/Lower Body/conditions/is_dashing", is_dashing)
	set("parameters/Lower Body/conditions/is_jumping", is_jumping)
	
	# BLEND TREES #
	var current_direction = get("parameters/Lower Body/Walk/Blend/blend_position")
	var lerp_direction = current_direction.lerp(
		Vector2(direction.x, -direction.y), lower_blend_tree_lerp * delta
	)
	set("parameters/Lower Body/Walk/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Start/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Loop/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Stop/Blend/blend_position", lerp_direction)

func update_upper_body(delta):
	# CONDITIONS #
	
	# BLEND TREES #
	var current_look = get("parameters/Upper Body/Look - Empty/blend_position")
	var lerp_look = current_look.lerp(
		Vector2(look.x, -look.y), upper_blend_tree_lerp * delta
	)
	set("parameters/Upper Body/Look - Empty/blend_position", lerp_look)	
