extends Node3D
class_name JetpackController

@export var fuel: float = 100
@export var empty_indicator: Node3D
@export var is_dashing: bool = false
@export var is_double_jumping: bool = false

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

func _ready():
	play_jet_beam()

func _process(delta):
	spend_fuel(delta)
	play_jet_stream()
	if is_double_jumping:
		play_jet_beam()
	if fuel <= 0:
		empty_indicator.visible = true
	else:
		empty_indicator.visible = false

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
