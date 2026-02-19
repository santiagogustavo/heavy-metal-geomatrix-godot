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
	WorldBoundary = 16,
	InvisibleWall = 32,
	Hitbox = 64,
	Weapon = 128,
	Glass = 4 + 256,
	Water = 4 + 512,
	Stone = 4 + 1024,
	Dirt = 4 + 2048,
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
	Mayfly,
	Slash,
	Kassey,
	Di,
	Hound,
	Pufferson,
}

const TeamNames: Dictionary = {
	Teams.Stompers: "818 Stompers",
	Teams.Elite: "911 Elite",
	Teams.Metalheads: "707 Metalheads",
	Teams.Agents: "323 Agents"
}

const CharacterNames: Dictionary = {
	Characters.Mayfly: "Mayfly",
	Characters.Slash: "Slash",
	Characters.Kassey: "Kassey",
	Characters.Di: "Di",
	Characters.Hound: "Hound",
	Characters.Pufferson: "Pufferson"
}

const Scenes: Dictionary = {
	"Loading": "res://Scenes/LoadingScreen.tscn",
	"Intro": "res://Scenes/Intro.tscn",
}

const Selects: Dictionary = {
	Characters.Mayfly: "res://Prefabs/Characters/Mayfly/Base.tscn",
	Characters.Slash: "res://Prefabs/Characters/Slash/Base.tscn",
	Characters.Kassey: "res://Prefabs/Characters/Kassey/Base.tscn",
	Characters.Di: "res://Prefabs/Characters/Di/Base.tscn",
	Characters.Hound: "res://Prefabs/Characters/Hound/Base.tscn"
}

const Players: Dictionary = {
	Characters.Mayfly: "res://Prefabs/Characters/Mayfly/Base.tscn",
	Characters.Slash: "res://Prefabs/Characters/Slash/Base.tscn",
	Characters.Kassey: "res://Prefabs/Characters/Kassey/Base.tscn",
	Characters.Di: "res://Prefabs/Characters/Di/Base.tscn",
	Characters.Hound: "res://Prefabs/Characters/Hound/Base.tscn",
	Characters.Pufferson: "res://Prefabs/Characters/Pufferson/Base.tscn"
}

const WeaponRange: Dictionary = {
	"Min": 1.4,
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
