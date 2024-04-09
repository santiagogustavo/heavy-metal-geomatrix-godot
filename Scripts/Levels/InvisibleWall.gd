extends CollisionShape3D

@export var material: Material

@onready var boxSize: Vector3 = shape.size
@onready var meshInstance: MeshInstance3D = MeshInstance3D.new()
@onready var boxMesh: BoxMesh = BoxMesh.new()

func _ready():
	boxMesh.size = boxSize
	boxMesh.material = material
	meshInstance.mesh = boxMesh
	add_child(meshInstance)

func _process(_delta):
	var index = 1
	for player in GameManager.players:
		if (index <= 6):
			material.set("shader_parameter/pos" + str(index), player.global_position)
		index += 1
