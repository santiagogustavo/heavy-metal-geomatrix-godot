extends Node3D
class_name Item

@export_category("Properties")
@export var item_name: String
@export var equip_type: Definitions.EquipType
@export var splash: Texture2D

var player_rid: RID
