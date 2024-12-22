class_name DebugCommands

var autocomplete_methods: Array = []

func _get_autocomplete_info() -> void:
	autocomplete_methods = get_script().get_script_method_list().map(func (x: Dictionary) -> String: return x.name)
	autocomplete_methods = autocomplete_methods.filter(func (x: String) -> bool: return not x.begins_with("_"))

func _get_autocomplete_match(input: String) -> String:
	for method: String in autocomplete_methods:
		if method.begins_with(input):
			return method
	return input
	

func hello() -> String:
	return "Hello!"

func change_player_skin(skin: int) -> void:
	var player = GameManager.get_player_one()
	player.selected_skin = clamp(skin, 0, player.character.skins.size() - 1)
