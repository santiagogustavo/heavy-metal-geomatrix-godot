extends GunFireMode
class_name GunBulletMode

@export_subgroup("Bullet")
@export var bullets: int
@export var fire_rate: float
@export var burst_count: int
@export var burst_rate: float
@export var spray_amount: float
@export var bullet: PackedScene
@export var ejecting_brass: PackedScene

@onready var total_bullets: int = bullets

const type: GunBulletMode.Type = GunBulletMode.Type.Bullet
