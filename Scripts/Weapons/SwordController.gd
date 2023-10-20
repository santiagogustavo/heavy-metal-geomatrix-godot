extends Node3D
class_name SwordController

@export var is_attacking = false
@onready var trail = $GPUTrail3D
@onready var collider = $StaticBody3D

func _ready():
	collider.connect("body_entered", _on_body_entered)

func _process(_delta):
	trail.set_process(is_attacking)
	trail.visible = is_attacking

func _on_body_entered(body: Node3D):
	print_debug(body.name)
	#print_debug(collider.get_contact_count())
