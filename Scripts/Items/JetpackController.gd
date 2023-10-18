extends Node3D
class_name JetpackController

@export var fuel: float = 100
@export var empty_indicator: Node3D
@export var is_dashing: bool = false
@export var is_double_jumping: bool = false

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

func _ready():
	play_jet_beam()

func _process(delta):
	spend_fuel(delta)
	randomize_lights_energy()
	enable_or_disable_indicator()
	enable_or_disable_lights()
	play_jet_stream()
	if is_double_jumping:
		double_jumped = true
		get_tree().create_timer(0.1).connect("timeout", _on_double_jump_timeout)
		play_jet_beam()

func _on_double_jump_timeout():
	double_jumped = false

func randomize_lights_energy():
	for light in jet_lights:
		light.light_energy = randf_range(0.01, 0.3)

func enable_or_disable_indicator():
	empty_indicator.visible = fuel <= 0

func enable_or_disable_lights():
	for light in jet_lights:
		light.visible = fuel > 0 and (is_dashing or double_jumped)

func spend_fuel(delta):
	if fuel <= 0:
		return
	if is_dashing:
		fuel -= 15 * delta
	if is_double_jumping:
		fuel -= 20

func play_jet_smoke():
	for particle in jet_smoke:
		particle.emitting = true

func play_jet_beam():
	if fuel <= 0:
		smoke_sfx.playing = true
		play_jet_smoke()
		return

	beam_sfx.playing = true
	for particle in jet_beam:
		particle.emitting = true

func play_jet_stream():
	if fuel <= 0:
		if is_dashing and !smoke_sfx.playing:
			smoke_sfx.playing = true
			play_jet_smoke()

	var is_emitting = is_dashing and fuel > 0
	if loop_sfx.playing != is_emitting:
		loop_sfx.playing = is_emitting
	for particle in jet_stream:
		particle.emitting = is_emitting
