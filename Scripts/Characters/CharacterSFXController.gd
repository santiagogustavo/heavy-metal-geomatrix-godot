extends Node3D
class_name CharacterSFXController

@onready var hurt_sfx: AudioStreamPlayer3D = $Hit

@onready var walk_dirt_sfx: AudioStreamPlayer3D = $Common/WalkDirt
@onready var walk_stone_sfx: AudioStreamPlayer3D = $Common/WalkStone
@onready var walk_water_sfx: AudioStreamPlayer3D = $Common/WalkWater
@onready var walk_default_sfx: AudioStreamPlayer3D = $Common/WalkDefault
@onready var land_dirt_sfx: AudioStreamPlayer3D = $Common/LandDirt
@onready var land_stone_sfx: AudioStreamPlayer3D = $Common/LandStone
@onready var land_water_sfx: AudioStreamPlayer3D = $Common/LandWater
@onready var land_default_sfx: AudioStreamPlayer3D = $Common/LandDefault

var is_walking: bool = false
var current_collision_surface: Definitions.SurfaceType = Definitions.SurfaceType.LevelGeometry

func play_hurt_sound() -> void:
	if !hurt_sfx.playing:
		hurt_sfx.play()

func play_walk_sound_if_walking() -> void:
	if !is_walking:
		return
	play_surface_walk_sound()

func play_surface_walk_sound() -> void:
	match current_collision_surface:
		Definitions.SurfaceType.Dirt, Definitions.SurfaceType.InvisibleDirt:
			walk_dirt_sfx.playing = true
			pass
		Definitions.SurfaceType.Stone, Definitions.SurfaceType.InvisibleStone:
			walk_stone_sfx.playing = true
			pass
		Definitions.SurfaceType.Water, Definitions.SurfaceType.InvisibleWater:
			walk_water_sfx.playing = true
			pass
		_:
			walk_default_sfx.playing = true

func play_surface_land_sound() -> void:
	match current_collision_surface:
		Definitions.SurfaceType.Dirt, Definitions.SurfaceType.InvisibleDirt:
			land_dirt_sfx.playing = true
			pass
		Definitions.SurfaceType.Stone, Definitions.SurfaceType.InvisibleStone:
			land_stone_sfx.playing = true
			pass
		Definitions.SurfaceType.Water, Definitions.SurfaceType.InvisibleWater:
			land_water_sfx.playing = true
			pass
		_:
			land_default_sfx.playing = true
