@tool
extends MultiMeshInstance3D

@export var layer_count = 16
@export var mesh : Mesh

@export_tool_button("Populate", "MultiMeshInstance3D")
var action = populate

func populate() -> void:
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = layer_count
	var material : ShaderMaterial = material_override
	material.set_shader_parameter("layers", float(layer_count + 1))
	var index := 0
	while index < layer_count:
		multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, Vector3.ZERO))
		index += 1
