extends Node

var persistent_nodes: Array[Node] = []

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
	LoadingOverlay.is_loading = true
	ResourceLoader.load_threaded_request(file)
	var thread_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(file)
	while thread_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		thread_status = ResourceLoader.load_threaded_get_status(file)
	get_tree().create_timer(0.5).timeout.connect(func ():
		if thread_status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(file)
			get_tree().change_scene_to_packed(scene)
			LoadingOverlay.is_loading = false
	)
