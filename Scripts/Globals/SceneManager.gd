extends Node

var persistent_nodes: Array[Node] = []
var scene_file: String
var scene_loaded: bool = true

func persist_node(node: Node) -> void:
	node.reparent.call_deferred(get_tree().root)
	persistent_nodes.append(node)

func remove_persistent_node_by_name(node_name: String) -> void:
	var index: int = persistent_nodes.map(func (node: Node): return node.name).find(node_name)
	persistent_nodes[index].queue_free()
	persistent_nodes.remove_at(index)

func get_persistent_node_by_name(node_name: String) -> Node:
	var index: int = persistent_nodes.map(func (node: Node): return node.name).find(node_name)
	if index == -1:
		return null
	return persistent_nodes[index]

func load_scene_file(file: String) -> void:
	scene_loaded = false
	scene_file = file
	LoadingOverlay.is_loading = true
	ResourceLoader.load_threaded_request(scene_file)

func _process(_delta: float) -> void:
	if scene_loaded:
		return
	var thread_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_file)
	if thread_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene_loaded = true
		get_tree().create_timer(0.5).timeout.connect(func ():
			var scene = ResourceLoader.load_threaded_get(scene_file)
			get_tree().change_scene_to_packed(scene)
			LoadingOverlay.is_loading = false
		)
