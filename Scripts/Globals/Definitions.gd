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
	Glass = 4 + 256,
	Water = 4 + 512,
	Stone = 4 + 1024,
	Dirt = 4 + 2048
}

var Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
