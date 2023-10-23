extends AnimationTree

@export var equip_type: Definitions.EquipType

@export var is_current_node_attacking = false
@export var animation_has_changed = false
@export var current_animation: String

var equip_body = false
var equip_melee_light = false
var equip_melee_heavy = false
var last_animation: String

func _process(_delta):
	equip_body = equip_type == Definitions.EquipType.Body
	equip_melee_light = equip_type == Definitions.EquipType.MeleeLight
	equip_melee_heavy = equip_type == Definitions.EquipType.MeleeHeavy
	animation_has_changed = current_animation != last_animation
	last_animation = current_animation
