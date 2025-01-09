extends Node
class_name FileSystem

static func forFilesInDirectory(
	path: String,
	fileAction: Callable,
	includeSubdirectories: bool = false
) -> void:
	var dir: DirAccess = DirAccess.open(path)
	dir.list_dir_begin()
	
	var filename: String = ''
	var is_empty: bool = false
	while not is_empty:
		filename = dir.get_next()
		is_empty = (!filename or filename == '')
		var current_path: String = path + "/" + filename
		if is_empty:
			break
		if !dir.current_is_dir():
			fileAction.call(filename, current_path)
		elif includeSubdirectories:
			forFilesInDirectory(current_path, fileAction, true)
	dir.list_dir_end()
