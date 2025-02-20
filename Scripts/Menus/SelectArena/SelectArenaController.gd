extends Control

signal selected

@export_file var redirect_to_scene: String

@export_subgroup("Definitions")
@export var arena_cards: Array[ArenaCard]

@export_subgroup("References")
@export var arena_splash: TextureRect
@export var arena_name_label: Label
@export var weather_label: Label
@export var rules_rounds_label: Label
@export var rules_time_label: Label
@export var open_rules_menu_button: Button

@export_subgroup("SFX")
@export var cursor_sfx: AudioStreamPlayer2D
@export var select_sfx: AudioStreamPlayer2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_card: ArenaCard

var is_selected: bool = false
var focused_first: bool = false

var rules_rounds: int = 2
var rules_time: int = 60

func _ready() -> void:
	open_rules_menu_button.button_down.connect(func ():
		RulesMenuController.is_menu_open = true
	)
	RulesMenuController.instance.change_rounds.connect(func (rounds: int):
		rules_rounds = rounds
	)
	RulesMenuController.instance.change_time.connect(func (time: int):
		rules_time = time
	)
	if !arena_cards or !arena_cards.size():
		return
	for arena in arena_cards:
		selected.connect(func (arena_name: String):
			if arena_name != arena.name:
				arena.focus_mode = Control.FOCUS_NONE
				arena.disabled = true
		)
		arena.focus_entered.connect(func ():
			current_card = arena
			cursor_sfx.play()
			update_arena_name_label(arena.level_config.level_name)
			update_arena_splash(arena.level_config.splash)
			update_weather_label(get_weather_label(arena.level_config))
			animation_player.play("Glitch")
		)
		arena.button_down.connect(func ():
			if is_selected:
				return
			is_selected = true
			select_sfx.play()
			selected.emit(arena.name)
			select_arena(arena)
		)
	focus_on_first()

func _process(_delta: float) -> void:
	set_process_input(!DebugMenuManager.is_menu_open and !RulesMenuController.is_menu_open)
	update_rules_rounds_label(rules_rounds)
	update_rules_time_label(rules_time)
	if DebugMenuManager.is_menu_open:
		focused_first = false
	elif !focused_first:
		if !RulesMenuController.is_menu_open:
			focus_on_first()
		else:
			RulesMenuController.instance.focus_on_first()

func _exit_tree() -> void:
	var ost_node: Node = SceneManager.get_persistent_node_by_name("OST")
	if ost_node:
		SceneManager.remove_persistent_node_by_name("OST")

func select_arena(arena: ArenaCard) -> void:
	GameManager.create_match(MatchManager.new())
	GameManager.current_match.rounds = rules_rounds
	GameManager.current_match.time = rules_time
	await get_tree().create_timer(1.0).timeout
	SceneManager.load_scene_file(arena.arena_scene)

func focus_on_first():
	focused_first = true
	if current_card:
		current_card.grab_focus()
	else:
		arena_cards[0].grab_focus()

func update_arena_splash(splash: Texture2D) -> void:
	arena_splash.texture = splash

func update_arena_name_label(arena_name: String) -> void:
	arena_name_label.text = arena_name

func get_weather_label(level_config: LevelConfig) -> String:
	if level_config.is_rainy:
		return "Rainy"
	elif level_config.is_snowy:
		return "Snowy"
	else:
		return "Sunny"


func update_weather_label(weather: String) -> void:
	weather_label.text = weather

func update_rules_rounds_label(rounds: int) -> void:
	rules_rounds_label.text = str(rounds)

func update_rules_time_label(time: int) -> void:
	rules_time_label.text = str(time)
