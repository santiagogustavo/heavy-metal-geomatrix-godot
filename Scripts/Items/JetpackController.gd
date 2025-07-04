extends Item
class_name JetpackController

@export var fuel: float = 100
@export var empty_indicator: Node3D
@export var is_dashing: bool = false
@export var is_double_jumping: bool = false

var fuel_cost_dash = 15
var fuel_cost_jump = 20

@onready var jet_lights: Array[OmniLight3D] = [
	$L/JetLight,
	$R/JetLight
]
@onready var jet_beam: Array[GPUParticles3D] = [
	$L/JetBeam, $L/JetBeam/JetBase,
	$R/JetBeam, $R/JetBeam/JetBase
]
@onready var jet_stream: Array[GPUParticles3D] = [
	$L/JetStream, $L/JetStream/JetBase,
	$R/JetStream, $R/JetStream/JetBase
]
@onready var jet_smoke: Array[GPUParticles3D] = [
	$L/JetSmoke,
	$R/JetSmoke,
]

@onready var beam_sfx: AudioStreamPlayer3D = $SFX/Beam
@onready var loop_sfx: AudioStreamPlayer3D = $SFX/Loop
@onready var smoke_sfx: AudioStreamPlayer3D = $SFX/Smoke

var double_jumped = false

func _ready() -> void:
	play_jet_beam()

func _process(delta: float) -> void:
	spend_fuel(delta)
	randomize_lights_energy()
	enable_or_disable_indicator()
	enable_or_disable_lights()
	play_jet_stream()
	if is_double_jumping:
		double_jumped = true
		get_tree().create_timer(0.1).connect("timeout", _on_double_jump_timeout)
		play_jet_beam(true)

func _on_double_jump_timeout() -> void:
	double_jumped = false

func randomize_lights_energy() -> void:
	for light in jet_lights:
		light.light_energy = randf_range(0.01, 0.3)

func enable_or_disable_indicator() -> void:
	empty_indicator.visible = fuel <= 0

func enable_or_disable_lights() -> void:
	for light in jet_lights:
		light.visible = fuel > 0 and (is_dashing or double_jumped)

func spend_fuel(delta) -> void:
	if fuel <= 0:
		return
	if is_dashing:
		fuel -= fuel_cost_dash * delta
	if is_double_jumping:
		fuel -= fuel_cost_jump

func play_jet_smoke() -> void:
	for particle in jet_smoke:
		particle.emitting = true

func play_jet_beam(force_beam: bool = false) -> void:
	if fuel <= 0 and !force_beam:
		smoke_sfx.playing = true
		play_jet_smoke()
		return
	if player_rid == GameManager.get_player_one().get_rid():
		InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
	beam_sfx.playing = true
	for particle in jet_beam:
		particle.emitting = true

func play_jet_stream() -> void:
	if fuel <= 0:
		if is_dashing and !smoke_sfx.playing:
			smoke_sfx.playing = true
			play_jet_smoke()

	var is_emitting = is_dashing and fuel > 0
	if is_emitting and player_rid == GameManager.get_player_one().get_rid():
		InputManager.vibrate_controller(0, 0.0, 0.5, 0.2)
	if loop_sfx.playing != is_emitting:
		loop_sfx.playing = is_emitting
	for particle in jet_stream:
		particle.emitting = is_emitting
