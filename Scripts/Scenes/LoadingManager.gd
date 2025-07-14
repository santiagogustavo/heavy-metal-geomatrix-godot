extends CanvasLayer
class_name LoadingManager

static var next_scene: String = Definitions.Scenes.Intro
static var finished_precompiling: bool = false
@onready var compiler_parent: Node3D = $CompilerParent

static var files_to_compile: Array[String] = []
static var compiled_material_paths: Array[String] = []
static var compiled_particles_paths: Array[String] = []

var to_compile_count: int = 0
var compiled_count: int = 0

func _ready() -> void:
	GameManager.current_scene_type = Definitions.SceneType.Loading
	await get_tree().create_timer(1).timeout
	if !finished_precompiling:
		parseScenePathsToCompile()
		compileScannedFiles()
	ResourceLoader.load_threaded_request(next_scene)

func _process(_delta: float) -> void:
	finished_precompiling = compiled_count == to_compile_count
	var progress: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(next_scene)
	if progress == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and finished_precompiling:
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)

func compileScannedFiles() -> void:
	for path: String in files_to_compile:
		compileFile(path)
		files_to_compile.erase(path)
	finished_precompiling = true

func compileFile(path: String) -> void:
	print_debug("[PRECOMPILER] Processing \"" + path + "\"...")
	var resource: Resource = ResourceLoader.load(path)
	if !resource or !resource.has_method("instantiate"):
		return
	var node = resource.instantiate()

	if node is GPUParticles3D:
		compileMaterialParticle(node, path)
	elif node is MeshInstance3D:
		compileMaterialMesh(node, path)

	var children: Array[Node] = node.get_children(true)
	for child: Node in children:
		#print_debug("[PRECOMPILER] Processing child \"" + child.name + "\"...")
		if child is GPUParticles3D:
			to_compile_count += 1
			compileMaterialParticle(child, path)
		elif child is MeshInstance3D:
			to_compile_count += 1
			compileMaterialMesh(child, child.name)
	node.queue_free()

func compileMaterialMesh(instance: MeshInstance3D, path: String) -> void:
	if compiled_material_paths.has(path):
		to_compile_count -= 1
		print_debug("[PRECOMPILER] Found \"" + path + "\" in cache. Skipping...")
		return
	print_debug("[PRECOMPILER] Inserting \"" + path + "\" into cache...")
	var compiled = MeshInstance3D.new()
	compiled.mesh = instance.mesh
	compiler_parent.add_child(compiled)
	compiled_material_paths.append(path)
	get_tree().create_timer(0.5).connect("timeout", func ():
		print_debug("[PRECOMPILER] Compiled \"" + path + "\".")
		compiled_count += 1
		compiled.queue_free()
	)

func compileMaterialParticle(particle: GPUParticles3D, path: String) -> void:
	if compiled_particles_paths.has(path):
		to_compile_count -= 1
		print_debug("[PRECOMPILER] Found \"" + path + "\" in cache. Skipping...")
		return
	print_debug("[PRECOMPILER] Inserting \"" + path + "\" into cache...")
	
	var compiled = GPUParticles3D.new()
	compiled.process_material = particle.process_material
	compiled.emitting = true
	compiled.draw_passes = particle.draw_passes
	
	compiler_parent.add_child(compiled)
	compiled_particles_paths.append(path)
	get_tree().create_timer(0.5).connect("timeout", func ():
		print_debug("[PRECOMPILER] Compiled \"" + path + "\".")
		compiled_count += 1
		compiled.queue_free()
	)

static func parseScenePathsToCompile() -> void:
	var regexPattern: String = "(sub_resource|ext_resource|gd_resource) type=\"(ParticleProcessMaterial|ShaderMaterial|StandardMaterial3D|GPUParticles3D|CanvasItemMaterial|Material)\""
	var regex: RegEx = RegEx.create_from_string(regexPattern)
	var regexExtensionsPattern: String = ".(tscn|tres|gdshader)"
	var regexExtensions: RegEx = RegEx.create_from_string(regexExtensionsPattern)
	var fileList: Array[String] = []
	FileSystem.forFilesInDirectory("res://Materials", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	FileSystem.forFilesInDirectory("res://Models", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	FileSystem.forFilesInDirectory("res://Prefabs", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	FileSystem.forFilesInDirectory("res://Scenes", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	
	var instantiationList: Array[String] = []
	for filePath: String in fileList:
		var extensionSearch = regexExtensions.search(filePath)
		var file = FileAccess.open(filePath, FileAccess.ModeFlags.READ)
		if !file or !extensionSearch:
			continue
		var text: String = file.get_as_text()
		var result: RegExMatch = regex.search(text)
		if result:
			instantiationList.append(filePath)
	for scenePath: String in instantiationList:
		files_to_compile.append(scenePath)
