class_name DebugCommands

signal clear_console

var autocomplete_methods: Array = []

var foo: String = 'Hello!'

var is_stats_overlay_open: bool = false 

func _get_autocomplete_info() -> void:
	autocomplete_methods = get_script().get_script_method_list().map(func (x: Dictionary) -> String: return x.name)
	autocomplete_methods = autocomplete_methods.filter(func (x: String) -> bool: return not x.begins_with("_"))

func _get_autocomplete_match(input: String) -> String:
	for method: String in autocomplete_methods:
		if method.begins_with(input):
			return method
	return input

func hello(text: String = foo) -> String:
	return text

func clear() -> void:
	clear_console.emit()

func change_player_skin(skin: int) -> void:
	var player = GameManager.get_player_one()
	player.selected_skin = clamp(skin, 0, player.character.skins.size() - 1)

func show_stats() -> void:
	is_stats_overlay_open = !is_stats_overlay_open

func start_round() -> String:
	if GameManager.current_match:
		var success = GameManager.current_match.start_round()
		if success:
			return "Round " + str(GameManager.current_match.current_round) + " started!"
		else:
			return "Round " + str(GameManager.current_match.current_round) + " already ongoing!"
	else:
		return "No matches available"

func end_round() -> String:
	if GameManager.current_match:
		var success = GameManager.current_match.end_round()
		if success:
			return "Round " + str(GameManager.current_match.current_round) + " ended!"
		else:
			return "Round " + str(GameManager.current_match.current_round) + " already ended or not started"
	else:
		return "No matches available"
