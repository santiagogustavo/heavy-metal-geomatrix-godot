extends MeshInstance3D
class_name InvisibleWall

@onready var material = mesh.material

func _process(delta):
	var index = 1
	for player in GameManager.players:
		if (index <= 6):
			material.set("shader_parameter/pos" + str(index), player.global_position)
		index += 1
