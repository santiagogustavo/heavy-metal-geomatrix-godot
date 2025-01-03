extends CharacterBody3D
class_name Player

enum PlayerType {
	Player1,
	Player2,
	Bot,
}

@export_subgroup("Properties")
@export var player_name: String
@export_range(0, 100) var health: int = 100
@export var selected_skin: int = 1

@export_subgroup("Controls")
@export var player_type: PlayerType = PlayerType.Player1

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera

@onready var character: CharacterController = $CharacterController
@onready var animation_tree = $CharacterController/AnimationTree
@onready var sound_tree = $CharacterController/SoundAnimationTree
@onready var sound_attack_tree = $CharacterController/SoundAttackTree
@onready var dash = $Dash
@onready var inventory_manager: InventoryManager = $InventoryManager

var is_pickup_collided = false
var shoot_target = Vector3.ZERO

@onready var player_input: PlayerInputManager

var collided_pickup: PickupController

func _ready() -> void:
	match player_type:
		_:
			player_input = PlayerInputManager.new(player_type)
	player_input.camera_pivot = camera_pivot
	add_child(player_input)
	GameManager.add_player(self)

func _physics_process(delta: float) -> void:
	compute_gravity(delta)
	compute_movement()

func _process(_delta: float) -> void:
	update_internals()
	update_externals()
	set_sound_variables()
	set_animator_variables()
	set_camera_variables()
	set_inventory_items_variables()
	move_and_slide()

func _exit_tree() -> void:
	GameManager.remove_player(get_rid())

func heal_player(amount: int) -> void:
	health += amount
	health = clamp(health, 0, 100)

func damage_player(amount: int) -> void:
	health -= amount
	health = clamp(health, 0, 100)

func update_internals() -> void:
	rotation = player_input.rotation
	player_name = character.character_name
	character.current_skin = clamp(selected_skin, 0, character.skins.size() - 1)

func update_externals() -> void:
	player_input.is_on_floor = is_on_floor()
	player_input.can_double_jump = (
		inventory_manager.has_jetpack
		and inventory_manager.jetpack_can_jump
	)
	player_input.can_pickup = (
		is_pickup_collided
		and player_input.is_on_floor
	)
	dash.is_dashing = player_input.is_dashing
	dash.input_direction = player_input.input_direction
	dash.player_velocity = velocity

func compute_movement() -> void:
	var current_speed = character.speed
	if player_input.is_dashing and (!inventory_manager.has_jetpack or !inventory_manager.jetpack_has_fuel):
		current_speed = character.dashing_speed
	elif player_input.is_dashing and inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel:
		current_speed = character.jetpack_dashing_speed
	
	if player_input.is_walking:
		velocity.x = player_input.direction.x * current_speed
		velocity.z = player_input.direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	if player_input.is_jumping or player_input.is_double_jumping:
		velocity.y = character.jump_height

func compute_gravity(delta: float) -> void:
	velocity.y -= character.weight * Definitions.Gravity * delta

func set_camera_variables() -> void:
	camera.has_jetpack = inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel
	camera.is_dashing = player_input.is_dashing
	camera.is_aiming = player_input.is_aiming
	shoot_target = camera.target_point
	
func set_sound_variables() -> void:
	sound_tree.is_walking = player_input.is_walking
	sound_tree.is_jumping = player_input.is_jumping || player_input.is_double_jumping
	sound_tree.is_dashing = player_input.is_dashing
	sound_tree.is_picking_up = player_input.is_picking_up
	sound_tree.is_on_floor = is_on_floor()
	sound_attack_tree.equip_type = inventory_manager.equip_type
	sound_attack_tree.is_current_node_attacking = animation_tree.is_current_node_attacking()
	sound_attack_tree.current_animation = animation_tree.get_current_upper_body_animation()

func set_animator_variables() -> void:
	if inventory_manager.right_hand_instance != null and inventory_manager.right_hand_instance is GunController:
		animation_tree.is_shooting_locked = inventory_manager.right_hand_instance.is_shooting_locked
	animation_tree.equip = inventory_manager.equip_type
	animation_tree.direction = player_input.input_direction
	animation_tree.look = Vector2(0, player_input.input_look.y)
	animation_tree.is_dashing = player_input.is_dashing
	animation_tree.is_jumping = player_input.is_jumping
	animation_tree.is_double_jumping = player_input.is_double_jumping
	animation_tree.is_aiming = player_input.is_aiming
	animation_tree.is_gun_shooting = inventory_manager.is_gun_shooting
	animation_tree.is_holding_weapon = inventory_manager.is_holding_weapon
	animation_tree.is_shooting = player_input.is_shooting
	animation_tree.is_dropping = inventory_manager.is_dropping
	animation_tree.is_attacking = player_input.is_attacking
	animation_tree.is_picking_up = player_input.is_picking_up
	animation_tree.is_on_floor = is_on_floor()

func set_inventory_items_variables() -> void:
	if inventory_manager.body_instance:
		inventory_manager.body_instance.is_dashing = player_input.is_dashing
		inventory_manager.body_instance.is_double_jumping = player_input.is_double_jumping
	if inventory_manager.right_hand_instance != null:
		if inventory_manager.right_hand_instance is SwordController:
			inventory_manager.right_hand_instance.is_attacking = animation_tree.is_current_node_attacking()
		if inventory_manager.right_hand_instance is GunController:
			inventory_manager.right_hand_instance.is_shooting = player_input.is_shooting
			inventory_manager.right_hand_instance.target_point = shoot_target
