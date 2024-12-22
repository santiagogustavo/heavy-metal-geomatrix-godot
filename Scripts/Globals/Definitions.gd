extends Node

enum EquipType {
	Body,
	WeaponSingle,
	WeaponDouble,
	MeleeLight,
	MeleeHeavy
}

enum SceneType {
	Intro,
	Menu,
	LocalGame
}

enum SurfaceType {
	LevelGeometry = 4,
	WorldBoundary = 16,
	Glass = 4 + 256,
	Water = 4 + 512,
	Stone = 4 + 1024,
	Dirt = 4 + 2048
}
