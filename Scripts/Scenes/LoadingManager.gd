extends CanvasLayer
class_name LoadingManager

static var next_scene: String = Definitions.Scenes.Intro
static var finished_precompiling: bool = false
@onready var compiler_parent: Node = $CompilerParent

const PRECOMPILE_LIST: String = "res://Configs/precompile_list.config"
var files_to_compile: Array[String] = []
var compiled_material_paths: Array[String] = []
var compiled_particles_paths: Array[String] = []

func _ready() -> void:
	GameManager.current_scene_type = Definitions.SceneType.Loading
	await get_tree().create_timer(1).timeout
	if OS.is_debug_build():
		parseScenePathsToCompile()
	if !finished_precompiling:
		scanFilesToCompile()
		compileScannedFiles()
	ResourceLoader.load_threaded_request(next_scene)

func _process(_delta: float) -> void:
	var progress: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(next_scene)
	if progress == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and finished_precompiling:
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)

func scanFilesToCompile() -> void:
	var file: FileAccess = FileAccess.open(PRECOMPILE_LIST, FileAccess.ModeFlags.READ)
	
	var path: String = file.get_line()
	while path and path != "":
		files_to_compile.append(path)
		path = file.get_line()

func compileScannedFiles() -> void:
	for path: String in files_to_compile:
		compileFile(path)
		files_to_compile.erase(path)
	finished_precompiling = true

func compileFile(path: String) -> void:
	#print_debug("[PRECOMPILER] Processing \"" + path + "\"...")
	var scene: Node = (ResourceLoader.load(path) as PackedScene).instantiate()
	
	if scene is GPUParticles3D:
		compileMaterialParticle(scene, path)
	elif scene is MeshInstance3D:
		compileMaterialMesh(scene, path)

	var children: Array[Node] = scene.get_children(true)
	for child: Node in children:
		#print_debug("[PRECOMPILER] Processing child \"" + child.name + "\"...")
		if child is GPUParticles3D:
			compileMaterialParticle(child, path)
		elif child is MeshInstance3D:
			compileMaterialMesh(child, child.name)
	scene.queue_free()

func compileMaterialMesh(instance: MeshInstance3D, path: String) -> void:
	if compiled_material_paths.has(path):
		print_debug("[PRECOMPILER] Found \"" + path + "\" in cache. Skipping...")
		return
	#print_debug("[PRECOMPILER] Inserting \"" + path + "\" into cache...")
	var compiled = MeshInstance3D.new()
	compiled.mesh = instance.mesh
	compiler_parent.add_child(compiled)
	compiled_material_paths.append(path)
	get_tree().create_timer(0.5).connect("timeout", func ():
		if compiled:
			compiled.queue_free()
	)

func compileMaterialParticle(particle: GPUParticles3D, path: String) -> void:
	if compiled_particles_paths.has(path):
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
		if compiled:
			compiled.queue_free()
	)

static func parseScenePathsToCompile() -> void:
	var scenePathList: Array[String] = []
	var regexPattern: String = "(sub_resource|ext_resource) type=\"(ParticleProcessMaterial|ShaderMaterial|CanvasItemMaterial|Material)\""
	var regex: RegEx = RegEx.create_from_string(regexPattern)
	var fileList: Array[String] = []
	FileSystem.forFilesInDirectory("res://Prefabs", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	FileSystem.forFilesInDirectory("res://Scenes", Callable(func (_pass, filepath: String) -> void: fileList.append(filepath)), true)
	
	var instantiationList: Array[String] = []
	for filePath: String in fileList:
		var file = FileAccess.open(filePath, FileAccess.ModeFlags.READ)
		if !file or filePath.contains(".tmp"):
			continue
		var text: String = file.get_as_text()
		var result: RegExMatch = regex.search(text)
		if result:
			instantiationList.append(filePath)
	
	var saveFile: FileAccess = FileAccess.open(PRECOMPILE_LIST, FileAccess.ModeFlags.WRITE)
	for scenePath: String in instantiationList:
		saveFile.store_line(scenePath)
