extends CollisionShape3D
class_name InvisibleWall

@export var material: Material

@onready var box_size: Vector3 = shape.size
@onready var mesh_instance: MeshInstance3D = MeshInstance3D.new()
@onready var box_mesh: BoxMesh = BoxMesh.new()

func _ready() -> void:
	box_mesh.size = box_size
	box_mesh.material = material
	mesh_instance.mesh = box_mesh
	add_child(mesh_instance)

func _process(_delta: float) -> void:
	var index = 1
	for team: Team in GameManager.teams:
		for player: Player in team.players:
			if player.is_inside_tree() and index <= 6:
				material.set("shader_parameter/pos" + str(index), player.global_position)
			index += 1
