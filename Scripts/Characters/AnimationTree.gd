extends AnimationTree

var upper_body_state_machine
var last_combo_animation

var direction = Vector2.ZERO
var look = Vector2.ZERO

var equip = Definitions.EquipType.Body

var is_dashing = false
var is_jumping = false
var is_on_floor = true
var is_aiming = false
var is_shooting = false
var is_bursting = false
var is_attacking = false
var is_attack_combo = false
var is_picking_up = false

var fire_rate = 1

const lower_blend_tree_lerp = 15
const upper_blend_tree_lerp = 20

func _ready():
	upper_body_state_machine = get("parameters/Upper Body/playback")

func _process(delta):
	update_lower_body(delta)
	update_upper_body(delta)
	update_combo_input()
	update_combo_animation()
	update_pickup()

func update_pickup():
	if is_picking_up:
		upper_body_state_machine.travel("Pickup")

func update_shot():
	upper_body_state_machine.travel("Shoot - Weapon Single")
	set("parameters/Upper Body/Shoot - Weapon Single/TimeSeek/seek_request", 0.0)

func update_drop(equip_type: Definitions.EquipType):
	if equip_type == Definitions.EquipType.WeaponSingle:
		upper_body_state_machine.travel("Drop - Weapon Single")
	elif equip_type == Definitions.EquipType.MeleeLight:
		upper_body_state_machine.travel("Drop - Melee Light")
	elif equip_type == Definitions.EquipType.MeleeHeavy:
		upper_body_state_machine.travel("Drop - Melee Heavy")

func update_combo_input():
	if (is_attacking and is_current_node_attacking() and !is_current_node_last_combo()):
		is_attack_combo = true

func update_combo_animation():
	var current_node = upper_body_state_machine.get_current_node()
	if (current_node != last_combo_animation):
		is_attack_combo = false
	
	last_combo_animation = current_node

func get_current_upper_body_animation():
	return upper_body_state_machine.get_current_node()

func is_current_node_shooting():
	var current_node = upper_body_state_machine.get_current_node()
	return current_node in [
		'Shoot - Weapon Single',
		'Shoot - Weapon Double'
	]

func is_current_node_attacking():
	var current_node = upper_body_state_machine.get_current_node()
	return current_node in [
		'Attack - Punch 1',
		'Attack - Punch 2',
		'Attack - Punch 3',
		'Attack - Punch 4',
		'Attack - Melee Light 1',
		'Attack - Melee Light 2',
		'Attack - Melee Light 3',
		'Attack - Melee Light 4',
		'Attack - Melee Heavy 1',
		'Attack - Melee Heavy 2',
		'Attack - Melee Heavy 3',
		'Attack - Melee Heavy 4'
	]

func is_current_node_last_combo():
	var current_node = upper_body_state_machine.get_current_node()
	return current_node in [
		'Attack - Punch 4',
		'Attack - Melee Light 4',
		'Attack - Melee Heavy 4'
	]

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
	set("parameters/Upper Body/conditions/equip", equip)
	set("parameters/Upper Body/conditions/is_aiming", is_aiming)
	set("parameters/Upper Body/conditions/is_shooting", is_shooting)
	set("parameters/Upper Body/conditions/is_attacking", is_attacking || is_attack_combo)
	
	# BLEND TREES #
	var current_look = get("parameters/Upper Body/Look - Empty/blend_position")
	var lerp_look = current_look.lerp(
		Vector2(look.x, -look.y), upper_blend_tree_lerp * delta
	)
	set("parameters/Upper Body/Look - Empty/blend_position", lerp_look)
	
	# WEAPON SINGLE #
	set("parameters/Upper Body/Look - Weapon Single/blend_position", lerp_look)
	set("parameters/Upper Body/Aim - Weapon Single/blend_position", lerp_look)
	set("parameters/Upper Body/Shoot - Weapon Single/Blend/blend_position", lerp_look)
	
	# WEAPON DOUBLE #
	set("parameters/Upper Body/Look - Weapon Double/blend_position", lerp_look)
	set("parameters/Upper Body/Aim - Weapon Double/blend_position", lerp_look)
	set("parameters/Upper Body/Shoot - Weapon Double/Blend/blend_position", lerp_look)
	
	# MELEE LIGHT #
	set("parameters/Upper Body/Look - Melee Light/blend_position", lerp_look)
	
	# MELEE HEAVY #
	set("parameters/Upper Body/Look - Melee Heavy/blend_position", lerp_look)
