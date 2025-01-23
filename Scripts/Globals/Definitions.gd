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
	LevelGeometry = 4,
	WorldBoundary = 16,
	InvisibleWall = 32,
	Glass = 4 + 256,
	Water = 4 + 512,
	Stone = 4 + 1024,
	Dirt = 4 + 2048,
	InvisibleWater = 32 + 512,
	InvisibleStone = 32 + 1024,
	InvisibleDirt = 32 + 2048
}

const Scenes: Dictionary = {
	"Loading": "res://Scenes/LoadingScreen.tscn",
	"Intro": "res://Scenes/Intro.tscn",
}

const Characters: Dictionary = {
	"Mayfly": "res://Prefabs/Characters/Mayfly.tscn"
}

var Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
