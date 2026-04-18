extends Node3D
class_name BreakableProp

@export_subgroup("Properties")
@export var pristine_node: PristineBody
@export var animation_tree: AnimationTree
@export var health: float = 100.0

enum PropState {
	Pristine,
	Broken
}

var prop_state: PropState = PropState.Pristine

func _ready() -> void:
	pristine_node.damage.connect(damage_taken)

func _physics_process(_delta: float) -> void:
	animation_tree.set("parameters/conditions/broken", prop_state == PropState.Broken)

func damage_taken(amount: float) -> void:
	health -= amount
	if health <= 0:
		health = 0
		prop_state = PropState.Broken
