extends AnimationTree
class_name PlayerAnimationTree

signal combo_animation_changed

var upper_body_state_machine: AnimationNodeStateMachinePlayback
var last_combo_animation: StringName

var direction: Vector2 = Vector2.ZERO
var look: Vector2 = Vector2.ZERO

var equip: Definitions.EquipType = Definitions.EquipType.Body

var is_dashing: bool = false
var is_jumping: bool = false
var is_double_jumping: bool = false
var is_on_floor: bool = true
var is_aiming: bool = false
var is_shooting: bool = false
var is_gun_shooting: bool = false
var is_holding_weapon: bool = false
var is_attacking: bool = false
var is_attack_combo: bool = false
var is_picking_up: bool = false
var is_dropping: bool = false
var is_shooting_locked: bool = false

var ko_anim: int = -1
var has_reset_player: bool = false

const lower_blend_tree_lerp: float = 15
const upper_blend_tree_lerp: float = 20

func _ready() -> void:
	upper_body_state_machine = get("parameters/Upper Body/playback")

func _process(delta: float) -> void:
	update_lower_body(delta)
	update_upper_body(delta)
	update_combo_input()
	update_combo_animation()
	update_fire_rate()
	update_pickup()
	update_double_jump()

func switch_to_reaction() -> void:
	has_reset_player = false
	set("parameters/Gameplay/blend_amount", 0.0)

func switch_to_gameplay() -> void:
	set("parameters/Gameplay/blend_amount", 1.0)

func reset_player() -> void:
	ko_anim = -1
	switch_to_gameplay()
	upper_body_state_machine.reset_state()
	has_reset_player = true

func play_ko_state() -> void:
	ko_anim = randi_range(1, 2)
	switch_to_reaction()

func update_pickup() -> void:
	if is_picking_up:
		upper_body_state_machine.travel("Pickup", true)

func update_fire_rate() -> void:
	if is_gun_shooting:
		set("parameters/Upper Body/Shoot - Weapon Single/TimeSeek/seek_request", 0.0)

func update_combo_input() -> void:
	if (is_attacking and is_current_node_attacking() and !is_current_node_last_combo()):
		is_attack_combo = true

func update_combo_animation() -> void:
	var current_node: StringName = upper_body_state_machine.get_current_node()
	if (current_node != last_combo_animation):
		combo_animation_changed.emit()
		is_attack_combo = false
	
	last_combo_animation = current_node

func update_double_jump() -> void:
	if is_double_jumping:
		set("parameters/Lower Body/Double Jump/TimeSeek/seek_request", 0.0)

func get_current_upper_body_animation() -> StringName:
	return upper_body_state_machine.get_current_node()

func is_current_node_shooting() -> bool:
	var current_node: StringName = upper_body_state_machine.get_current_node()
	return current_node.to_lower().contains('shoot')

func is_current_node_attacking() -> bool:
	var current_node: StringName = upper_body_state_machine.get_current_node()
	return current_node.to_lower().contains('attack')

func is_current_node_last_combo() -> bool:
	var regex = RegEx.new()
	regex.compile('attack[\\s\\S]*4')
	var current_node: StringName = upper_body_state_machine.get_current_node()
	return !!regex.search(current_node.to_lower())

func update_lower_body(delta: float) -> void:
	# CONDITIONS #
	set("parameters/Lower Body/conditions/is_dashing", is_dashing)
	set("parameters/Lower Body/conditions/is_jumping", is_jumping)
	
	# BLEND TREES #
	var current_direction: Vector2 = get("parameters/Lower Body/Walk/Blend/blend_position")
	var lerp_direction: Vector2 = current_direction.lerp(
		Vector2(direction.x, -direction.y), lower_blend_tree_lerp * delta
	)
	set("parameters/Lower Body/Walk/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Start/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Loop/Blend/blend_position", lerp_direction)
	set("parameters/Lower Body/Dash Stop/Blend/blend_position", lerp_direction)

func update_upper_body(delta: float) -> void:
	# CONDITIONS #
	set("parameters/Upper Body/conditions/equip", equip)
	set("parameters/Upper Body/conditions/is_aiming", is_aiming)
	set("parameters/Upper Body/conditions/is_shooting", is_shooting)
	set("parameters/Upper Body/conditions/is_attacking", is_attacking || is_attack_combo)
	set("parameters/Upper Body/conditions/is_dropping", is_dropping)
	
	# BLEND TREES #
	var current_look: Vector2 = get("parameters/Upper Body/Look - Empty/blend_position")
	var lerp_look: Vector2 = current_look.lerp(
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
