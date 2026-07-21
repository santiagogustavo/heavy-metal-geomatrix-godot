extends Node

enum PlayerType {
	Player1,
	Player2,
	Bot,
}

enum EquipType {
	Body,
	WeaponSingle,
	WeaponDouble,
	MeleeLight,
	MeleeHeavy
}

enum SceneType {
	Loading,
	Intro,
	Attract,
	MainMenu,
	PlayerSelection,
	LevelSelection,
	Versus,
	CharacterTaunt,
	RoundAnnouncement,
	MatchStarted
}

enum SurfaceType {
	Player = 1,
	LevelGeometry = 4,
	BladeOrProjectile = 8,
	WorldBoundary = 16,
	InvisibleWall = 32,
	Hitbox = 64,
	Weapon = 128,
	Glass = 4 + 256,
	Water = 4 + 512,
	Stone = 4 + 1024,
	Dirt = 4 + 2048,
	Mud = 4 + 8192,
	InvisibleWater = 32 + 512,
	InvisibleStone = 32 + 1024,
	InvisibleDirt = 32 + 2048
}

enum Teams {
	Stompers,
	Elite,
	Metalheads,
	Agents
}

enum Characters {
	Hound,
	Slash,
	Zeus,
	Sarge,
	Kassey,
	Stab,
	Duke,
	Di,
	Lance,
	Phantom,
	Mayfly,
	Talbot,
	#Pufferson,
}

enum Arenas {
	RedHotShrineDay,
	OceanCastleTwilight,
	SunkenCityNight,
	PitchDarkStadium,
	JungledTempleDay,
	BloodyPrison,
}

const TeamNames: Dictionary = {
	Teams.Stompers: "818 Stompers",
	Teams.Elite: "911 Elite",
	Teams.Metalheads: "707 Metalheads",
	Teams.Agents: "323 Agents"
}

const CharacterNames: Dictionary = {
	Characters.Hound: "Hound",
	Characters.Slash: "Slash",
	Characters.Zeus: "Zeus",
	Characters.Sarge: "Sarge",
	Characters.Kassey: "Kassey",
	Characters.Stab: "Stab",
	Characters.Duke: "Duke",
	Characters.Di: "Di",
	Characters.Lance: "Lance",
	Characters.Phantom: "Phantom",
	Characters.Mayfly: "Mayfly",
	Characters.Talbot: "Talbot",
	#Characters.Pufferson: "Pufferson",
}

const ArenaNames: Dictionary = {
	Arenas.RedHotShrineDay: "Red Hot Shrine Day",
	Arenas.OceanCastleTwilight: "Ocean Castle Twilight",
	Arenas.SunkenCityNight: "Sunken City Night",
	Arenas.PitchDarkStadium: "Pitch Dark Stadium",
	Arenas.JungledTempleDay: "Jungled Temple Day",
	Arenas.BloodyPrison: "Bloody Prison",
}

const Scenes: Dictionary = {
	"Loading": "res://Scenes/LoadingScreen.tscn",
	"Intro": "res://Scenes/Intro.tscn",
}

const Players: Dictionary = {
	Characters.Hound: "res://Prefabs/Characters/Hound/Base.tscn",
	Characters.Slash: "res://Prefabs/Characters/Slash/Base.tscn",
	Characters.Zeus: "res://Prefabs/Characters/Zeus/Base.tscn",
	Characters.Sarge: "res://Prefabs/Characters/Sarge/Base.tscn",
	Characters.Kassey: "res://Prefabs/Characters/Kassey/Base.tscn",
	Characters.Stab: "res://Prefabs/Characters/Stab/Base.tscn",
	Characters.Duke: "res://Prefabs/Characters/Duke/Base.tscn",
	Characters.Di: "res://Prefabs/Characters/Di/Base.tscn",
	Characters.Lance: "res://Prefabs/Characters/Lance/Base.tscn",
	Characters.Phantom: "res://Prefabs/Characters/Phantom/Base.tscn",
	Characters.Mayfly: "res://Prefabs/Characters/Mayfly/Base.tscn",
	Characters.Talbot: "res://Prefabs/Characters/Talbot/Base.tscn",
	#Characters.Pufferson: "res://Prefabs/Characters/Pufferson/Base.tscn",
}

const ArenaScenes: Dictionary = {
	Arenas.RedHotShrineDay: "res://Scenes/Levels/RedHotShrineDay/RedHotShrineDay.tscn",
	Arenas.OceanCastleTwilight: "res://Scenes/Levels/OceanCastleTwilight/OceanCastleTwilight.tscn",
	Arenas.SunkenCityNight: "res://Scenes/Levels/SunkenCityNight/SunkenCityNight.tscn",
	Arenas.PitchDarkStadium: "res://Scenes/Levels/PitchDarkStadium/PitchDarkStadium.tscn",
	Arenas.JungledTempleDay: "res://Scenes/Levels/JungledTempleDay/JungledTempleDay.tscn",
	Arenas.BloodyPrison: "res://Scenes/Levels/BloodyPrison/BloodyPrison.tscn",
}

const WeaponRange: Dictionary = {
	"Min": 2.0,
	"Max": 25.0,
}

var Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum PickupColor {
	Red,
	Green,
	Blue
}

var PickupColorHashes: Dictionary = {
	PickupColor.Red: "ff2f42",
	PickupColor.Green: "68fe9b",
	PickupColor.Blue: "2d78ff"
}
