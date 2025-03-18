extends CharacterBody3D
class_name Player

signal player_ready
signal player_killed

enum PlayerType {
	Player1,
	Player2,
	Bot,
}

@export_subgroup("Properties")
@export var player_name: String
@export_range(0, 100) var health: int = 100
@export var selected_character: Definitions.Characters
@export var selected_skin: int = 1

@export_subgroup("Controls")
@export var player_type: PlayerType

@export_subgroup("References")
@export var camera_pivot: Marker3D
@export var camera: PlayerCamera
@export var ko_pivot: KOCameraController
@export var round_pivot: RoundCameraController
@export var navigation_agent: NavigationAgent3D

@export_subgroup("Match")
@export var spawn_point: SpawnPoint
@export var team: Team

@onready var dash: GPUParticles3D = $Dash
@onready var raycast: RayCast3D = $RayCast3D

# Instances
var brain: PlayerBrain
var character: CharacterController
var sfx_controller: CharacterSFXController
var animation_tree: PlayerAnimationTree
var inventory_manager: InventoryManager

var is_pickup_collided: bool = false
var shoot_target: Vector3 = Vector3.ZERO

var player_input: PlayerInputManager
var player_ui: Node2D

var player_bot_ai: PlayerBotAI

var collided_pickup: PickupController

var current_speed: float = 0.0

var is_locked_on: bool = false
var lock_on_target: int = -1
var lock_on_instance: Node3D
var initial_camera_pivot_rotation: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO

var lock_on_prefab: Resource = preload("res://Prefabs/Player/LockOnTarget.tscn")
@onready var ko_offset: Vector3 = ko_pivot.position if ko_pivot else Vector3.ZERO

func _ready() -> void:
	brain = PlayerBrain.new()
	add_child(brain)
	match player_type:
		PlayerType.Player1:
			initial_camera_pivot_rotation = camera_pivot.rotation
			player_input = PlayerInputManager.new(self)
			player_input.camera_pivot = camera_pivot
			player_input.lock_on.connect(lock_on_to_next_target)
			player_input.target_raycast = camera.camera_target_raycast
			player_input.aim_assist_raycast = get_node('AimAssist')
			add_child(player_input)
			player_ui = load("res://Prefabs/Player/UI.tscn").instantiate()
			get_tree().root.add_child.call_deferred(player_ui)
		PlayerType.Bot:
			player_bot_ai = PlayerBotAI.new(self)
			add_child(player_bot_ai)
	character = load(Definitions.Players[selected_character]).instantiate()
	character.damage.connect(damage_player)
	add_child(character)
	player_name = character.character_name
	if character.sfx_controller:
		sfx_controller = character.sfx_controller
	if character.animation_tree:
		animation_tree = character.animation_tree
		player_killed.connect(func (): animation_tree.play_ko_state())
	inventory_manager = load("res://Prefabs/Player/InventoryManager.tscn").instantiate()
	inventory_manager.player_rid = get_rid()
	inventory_manager.character_controller = character
	add_child(inventory_manager)
	if character.initial_loadout:
		inventory_manager.pick_up_item(character.initial_loadout_slot, character.initial_loadout)
	reset_player_to_spawn()
	player_ready.emit()

func _physics_process(delta: float) -> void:
	compute_gravity(delta)
	compute_movement()
	if raycast.is_colliding():
		collide(raycast.get_collider())

func _process(_delta: float) -> void:
	update_internals()
	update_externals()
	look_at_target_position()
	set_animator_variables()
	set_camera_variables()
	set_inventory_items_variables()
	move_and_slide()

func _exit_tree() -> void:
	if player_ui:
		player_ui.queue_free()
	if player_input:
		player_input.queue_free()
	if player_bot_ai:
		player_bot_ai.queue_free()

func lock_on_to_next_target() -> void:
	if lock_on_instance:
		lock_on_instance.queue_free()
		lock_on_instance = null
	if lock_on_target == GameManager.get_enemies(team.name).size() - 1:
		lock_on_target = -1
	else:
		lock_on_target += 1
		if GameManager.get_enemies(team.name)[lock_on_target].health == 0:
			lock_on_to_next_target()
		lock_on_instance = lock_on_prefab.instantiate()
		lock_on_instance.position = Vector3(0, 1.0, 0)
		GameManager.get_enemies(team.name)[lock_on_target].add_child(lock_on_instance)

func reset_player_to_spawn() -> void:
	if spawn_point:
		position = spawn_point.global_position
		rotation = spawn_point.global_rotation
	brain.new_rotation = rotation
	if player_bot_ai:
		player_bot_ai.state = PlayerBotAI.AIState.Idle
	if animation_tree:
		animation_tree.reset_player()

func collide(collision: StaticBody3D):
	if sfx_controller:
		sfx_controller.current_collision_surface = collision.collision_layer as Definitions.SurfaceType

func heal_player(amount: int) -> void:
	health += amount
	health = clamp(health, 0, 100)

func damage_player(amount: int, is_critical: bool = false) -> void:
	health -= amount
	health = clamp(health, 0, 100)
	if health == 0:
		player_killed.emit()

func update_internals() -> void:
	if player_input:
		rotation = player_input.rotation
	character.current_skin = clamp(selected_skin, 0, character.skins.size() - 1)

func update_externals() -> void:
	if player_input:
		is_locked_on = lock_on_target != -1
		player_input.is_locked_on = is_locked_on
		if player_input.is_locked_on:
			target_position = GameManager.get_enemies(team.name)[lock_on_target].global_position + Vector3(0, 1.0, 0)
	brain.is_on_floor = is_on_floor()
	brain.can_double_jump = (
		inventory_manager.has_jetpack
		and inventory_manager.jetpack_can_jump
	)
	brain.can_pickup = (
		is_pickup_collided
		and brain.is_on_floor
	)
	dash.is_dashing = brain.is_dashing
	dash.input_direction = brain.input_direction
	dash.player_velocity = velocity

func look_at_target_position() -> void:
	#var initial_rotation: Vector3 = rotation
	#look_at(target_position)
	#rotation.x = initial_rotation.x
	#rotation.z = initial_rotation.z
	if player_input and player_input.is_locked_on:
		camera_pivot.look_at(target_position)
		brain.new_rotation = camera_pivot.global_rotation

func compute_movement() -> void:
	current_speed = character.speed
	if (
		brain.is_dashing
		and (!inventory_manager.has_jetpack or !inventory_manager.jetpack_has_fuel)
	):
		current_speed = character.dashing_speed
	elif (
		brain.is_dashing
		and inventory_manager.has_jetpack
		and inventory_manager.jetpack_has_fuel
	):
		current_speed = character.jetpack_dashing_speed
	
	if player_input and brain.is_walking:
		velocity.x = brain.direction.x * current_speed
		velocity.z = brain.direction.z * current_speed
	else:
		velocity.x = move_toward(brain.direction.x, 0, current_speed)
		velocity.z = move_toward(brain.direction.z, 0, current_speed)
	
	if brain.is_jumping or brain.is_double_jumping:
		velocity.y = character.jump_height

func switch_to_player_camera() -> void:
	if camera:
		camera.make_current()

func move_ko_pivot(new_position: Vector3, new_rotation: Vector3) -> void:
	ko_pivot.global_position = new_position + ko_offset
	ko_pivot.global_rotation = new_rotation

func compute_gravity(delta: float) -> void:
	velocity.y -= character.weight * Definitions.Gravity * delta

func set_camera_variables() -> void:
	if player_type == PlayerType.Bot:
		shoot_target = player_bot_ai.target_position
		return
	camera.has_jetpack = inventory_manager.has_jetpack and inventory_manager.jetpack_has_fuel
	camera.is_dashing = brain.is_dashing
	camera.is_aiming = brain.is_aiming
	shoot_target = camera.target_point

func set_animator_variables() -> void:
	if !animation_tree:
		return
	if inventory_manager.right_hand_instance != null and inventory_manager.right_hand_instance is GunController:
		animation_tree.is_shooting_locked = inventory_manager.right_hand_instance.is_shooting_locked
	if sfx_controller:
		sfx_controller.is_walking = brain.is_walking
	animation_tree.is_dashing = brain.is_dashing
	animation_tree.is_jumping = brain.is_jumping
	animation_tree.is_double_jumping = brain.is_double_jumping
	animation_tree.is_aiming = brain.is_aiming
	animation_tree.is_shooting = brain.is_shooting
	animation_tree.is_attacking = brain.is_attacking
	animation_tree.is_picking_up = brain.is_picking_up
	animation_tree.direction = brain.input_direction
	if player_input:
		animation_tree.look = Vector2(0, camera.global_rotation.x * -0.6)
	if player_bot_ai:
		animation_tree.look = Vector2(0, camera_pivot.global_rotation.x * -0.6)
	animation_tree.is_on_floor = brain.is_on_floor
	animation_tree.equip = inventory_manager.equip_type
	animation_tree.is_dropping = inventory_manager.is_dropping
	animation_tree.is_gun_shooting = (
		inventory_manager.is_gun_shooting
		if inventory_manager.right_hand_instance is GunController
		else brain.is_shooting
	)
	animation_tree.is_holding_weapon = inventory_manager.is_holding_weapon

func set_inventory_items_variables() -> void:
	if inventory_manager.body_instance:
		inventory_manager.body_instance.is_dashing = brain.is_dashing
		inventory_manager.body_instance.is_double_jumping = brain.is_double_jumping
	if inventory_manager.right_hand_instance != null:
		if inventory_manager.right_hand_instance is SwordController and animation_tree:
			inventory_manager.right_hand_instance.is_attacking = animation_tree.is_current_node_attacking()
		if (
			inventory_manager.right_hand_instance is GunController
			or inventory_manager.right_hand_instance is EnergyGunController
		):
			inventory_manager.right_hand_instance.is_shooting = brain.is_shooting
			inventory_manager.right_hand_instance.target_point = shoot_target
