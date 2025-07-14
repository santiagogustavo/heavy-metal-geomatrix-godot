# This script reads every node from scene_path and stores its shaders to
#create a cache. Some changes will be needed if you want to use it in your
#project. It's not perfect, there might be situations I didn't consider.
#
# To use it, add this script to the root of a scene with this structure:
# ShaderCache - Spatial
# + Materials - Spatial
# + Particles - Spatial
# L Skeleton - Skeleton 
# 
# The Skeleton node doesn't need bones, as far as I know. But I use a simple
#skeleton with only one bone created in Blender to make sure everything works.
#
# After adding the script to the scene, select the scene_path and click on the
#"Load Scene" script variable in the editor. It may take a while, depending on
#the size of your scene. Save the scene.
# To actually load the shaders in the game, you need to load this scene and add
#it to the tree with:
#   var shader_cache = load(path_to_this_scene).instance()
#   self.call_deferred("add_child", shader_cache)
#
# This script will remove itself from the tree later, so don't lose the variable
#shader_cache. You may need to free it manually.
#
# The materials MUST be visible to the camera for them to load (there's code for
#this in _process()), but it can be placed behind a loading screen.

extends Node

@export_file var scene_path: String
# These are basically buttons, to be used in the editor. Just click one of them
#to call their functions
@export var load_scene: bool = false
@export var reset: bool = false

var materials = []
var particle_materials = []
var materials_node
var skeleton_node
var mesh
var mmesh
var particles_node
var show_for_n_frames = 10

func _ready():
	if !OS.has_feature("editor"):
		set_process(true)
	else:
		set_process(false)

func _process(delta):
	if show_for_n_frames > 0:
		show_for_n_frames -= 1
		# ------------------------------------------------------------------
		# EDIT THIS TO PLACE THIS NODE IN FRONT OF YOUR CAMERA
		# ------------------------------------------------------------------
		self.global_transform = get_tree().get_nodes_in_group("camera")[0].\
		  global_transform
		self.transform.origin.z += 10
		# ------------------------------------------------------------------
		for particle in get_node("Particles").get_children():
			particle.emitting = true
	else:
		get_parent().remove_child(self)
		set_process(false)

func _load_scene(value):
	if !value:
		return
	
	_reset(true)
	
	var scene = load(scene_path).instance()
	materials_node = get_node("Materials")
	mesh = QuadMesh.new()
	mmesh = MultiMesh.new()
	mmesh.mesh = mesh
	mmesh.instance_count = 1
	particles_node = get_node("Particles")
	skeleton_node = get_node("Skeleton")
	
	load_materials(scene)
	
	scene.queue_free()
	
	materials.clear()
	particle_materials.clear()

# Go through every node in the scene, collecting their materials
func load_materials(root):
	for child in root.get_children():
		if child is MeshInstance3D:
			if child.material_override != null:
				var mat = child.material_override
				add_material(mat, child)
			
			if child.get_surface_material_count() > 0:
				for i in child.get_surface_material_count():
					var mat = child.get_surface_material(i)
					add_material(mat, child)
		
		if child is MultiMeshInstance3D:
			if child.material_override != null:
				var mat = child.material_override
				add_material(mat, child)
		
		if child is GPUParticles3D:
			if child.process_material != null:
				var mat = child.material_override
				var proc_mat = child.process_material
				add_particle_material(proc_mat, mat, child)
		
		if is_instance_valid(child):
			load_materials(child)


# Add the material from a MeshInstance or a MultiMeshInstance
func add_material(mat, node):
	while mat != null:
		# Ignore material if already loaded
		if materials.find(mat, 0) == -1:
			materials.push_back(mat)
			if node is MeshInstance3D:
				new_mesh_instance(mat, node)
			elif node is MultiMeshInstance3D:
				new_multimesh(mat, node)
		mat = mat.next_pass


# Add the process material and the material from particles
func add_particle_material(proc_mat, material, node):
	# Ignore material if already loaded
	if particle_materials.find(proc_mat, 0) == -1:
		particle_materials.push_back(proc_mat)
		new_particles(proc_mat, material, node)


# Create a MeshInstance with a QuadMesh to store the material
func new_mesh_instance(material, node):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	mesh_instance.name = node.name
	mesh_instance.cast_shadow = node.cast_shadow
	if node.get_parent() is Skeleton3D:
		skeleton_node.add_child(mesh_instance)
	else:
		materials_node.add_child(mesh_instance)
	mesh_instance.set_owner(self)


# Create a simple MultiMeshInstance to store the material
func new_multimesh(material, node):
	var multimesh = MultiMeshInstance3D.new()
	multimesh.multimesh = mmesh
	multimesh.material_override = material
	multimesh.name = node.name
	multimesh.cast_shadow = node.cast_shadow
	materials_node.add_child(multimesh)
	multimesh.set_owner(self)


# Create a simple Particles node to store the process material and the material
func new_particles(proc_mat, material, node):
	var particle = GPUParticles3D.new()
	particle.lifetime = 0.1
	particle.one_shot = true
	particle.emitting = false
	particle.draw_pass_1 = mesh
	particle.process_material = proc_mat
	particle.name = node.name
	particle.cast_shadow = node.cast_shadow
	particle.material_override = material
	particles_node.add_child(particle)
	particle.set_owner(self)


func _reset(value):
	if !value:
		return
	materials.clear()
	particle_materials.clear()
	for child in get_node("UI").get_children():
		child.queue_free()
	for child in get_node("Materials").get_children():
		child.queue_free()
	for child in get_node("Particles").get_children():
		child.queue_free()
