extends Item
class_name GunControllerV2

signal gun_shot
signal fire_mode_changed
signal drop

@export_subgroup("Properties")
@export var fire_modes: Array[GunFireMode]
@export var selected_fire_mode_index: int = 0
@export var share_ammo_and_energy: bool = true
@export var always_shoot_at_bullet_hole_direction: bool = false
@export var infinite_ammo: bool = false

@export_subgroup("References")
@export var animation_tree: GunAnimationTree
@export var bullet_holes: Array[Node3D]
@export var eject_hole: Node3D

# COMMON
var is_shooting: bool = false

# BULLET MODE
var is_shooting_locked: bool = false
var is_bursting: bool = false
var can_shoot: bool = false
var current_burst_count: int = 0

# ENERGY MODE
var frames_per_damage: int = 5
var frames_elapsed: int = 0
var can_damage: bool = true

@onready var target_point: Vector3 = Vector3.FORWARD * transform.basis * 100
var is_dropping: bool = false

@onready var selected_fire_mode: GunFireMode = null
var is_bullet_mode: bool = true
var is_energy_mode: bool = false
var has_mode_than_one_fire_mode: bool = false

func _ready() -> void:
	has_mode_than_one_fire_mode = fire_modes.size() > 1
	update_selected_fire_mode()

func _process(delta: float) -> void:
	if is_dropping:
		return
	var will_change_fire_mode = Input.is_action_just_pressed("switch_fire_mode")
	if will_change_fire_mode:
		if selected_fire_mode_index < fire_modes.size() - 1:
			selected_fire_mode_index += 1
		else:
			selected_fire_mode_index = 0
	if will_change_fire_mode or !selected_fire_mode:
		update_selected_fire_mode()
	if selected_fire_mode is GunBulletMode:
		is_bullet_mode = true
		is_energy_mode = false
		process_bullet_mode()
	elif selected_fire_mode is GunEnergyMode:
		is_bullet_mode = false
		is_energy_mode = true
		process_energy_mode(delta)

func _physics_process(delta: float) -> void:
	frames_elapsed += 1
	if selected_fire_mode and selected_fire_mode is GunEnergyMode:
		detect_raycast_collision(delta)

func update_selected_fire_mode() -> void:
	selected_fire_mode = fire_modes[selected_fire_mode_index]
	animation_tree.selected_fire_mode = selected_fire_mode.mode_name
	fire_mode_changed.emit()

func clear_current_fire_mode_and_go_to_next() -> void:
	selected_fire_mode.queue_free()
	is_bullet_mode = false
	is_energy_mode = false
	fire_modes.remove_at(selected_fire_mode_index)
	selected_fire_mode_index += 1
	if selected_fire_mode_index > fire_modes.size() - 1:
		selected_fire_mode_index = 0
	if fire_modes.size() == 0:
		drop.emit()
		is_dropping = true

func process_bullet_mode() -> void:
	if (selected_fire_mode as GunBulletMode).bullets <= 0:
		clear_current_fire_mode_and_go_to_next()
		return
	can_shoot = is_shooting and !is_shooting_locked
	animation_tree.is_shooting = is_shooting_locked
	animation_tree.is_bursting = is_bursting
	if can_shoot:
		update_fire_rate()

func process_energy_mode(delta: float) -> void:
	can_shoot = (selected_fire_mode as GunEnergyMode).energy > 0 and is_shooting
	can_damage = frames_elapsed >= frames_per_damage
	animation_tree.is_shooting = can_shoot
	if can_shoot:
		vibrate_soft()
		spend_fuel(delta)
	elif (selected_fire_mode as GunEnergyMode).energy == 0:
		clear_current_fire_mode_and_go_to_next()

# BULLET MODE

func update_fire_rate() -> void:
	is_shooting_locked = true
	current_burst_count = (selected_fire_mode as GunBulletMode).burst_count
	animation_tree.has_burst = (selected_fire_mode as GunBulletMode).burst_count > 0
	get_tree().create_timer((selected_fire_mode as GunBulletMode).fire_rate).connect("timeout", _unlock_fire)
	get_tree().create_timer((selected_fire_mode as GunBulletMode).burst_rate).connect("timeout", _burst_fire)

func _unlock_fire() -> void:
	is_shooting_locked = false

func _burst_fire() -> void:
	if current_burst_count == 0 or !selected_fire_mode:
		is_bursting = false
	else:
		is_bursting = true
		animation_tree.set("parameters/Shoot/TimeSeek/seek_request", 0.0)
		current_burst_count -= 1
		get_tree().create_timer(selected_fire_mode.burst_rate).connect("timeout", _burst_fire)

func instantiate_bullet(newPosition: Vector3, newBasis: Basis) -> Node3D:
	var bullet_instance: Bullet = selected_fire_mode.bullet.instantiate()
	bullet_instance.position = newPosition
	bullet_instance.transform.basis = newBasis
	bullet_instance.emissor_position = global_position
	bullet_instance.emissor_rid = player_rid
	get_tree().root.add_child(bullet_instance)
	return bullet_instance

func instantiate_brass(newPosition: Vector3, newBasis: Basis) -> Node3D:
	var brass_instance = selected_fire_mode.ejecting_brass.instantiate()
	brass_instance.position = newPosition
	brass_instance.transform.basis = newBasis
	get_tree().root.add_child(brass_instance)
	return brass_instance

func _shoot(hard: bool = false) -> void:
	if (
		!selected_fire_mode
		or selected_fire_mode is not GunBulletMode
		or (selected_fire_mode as GunBulletMode).bullets == 0
	):
		return
	gun_shot.emit()
	if !hard:
		vibrate_soft()
	else:
		vibrate_hard()
	for bullet_hole in bullet_holes:
		if !DebugCommands.full_ammo and !infinite_ammo:
			if share_ammo_and_energy:
				for fire_mode in fire_modes:
					if fire_mode is GunBulletMode:
						(fire_mode as GunBulletMode).bullets -= 1
			else:
				(selected_fire_mode as GunBulletMode).bullets -= 1
		var bullet_instance: Node3D = instantiate_bullet(bullet_hole.global_position, bullet_hole.global_transform.basis)
		if !always_shoot_at_bullet_hole_direction:
			TransformUtils.safe_look_at(bullet_instance, target_point)
		var spray_amount = (selected_fire_mode as GunBulletMode).spray_amount
		bullet_instance.rotate_x(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_y(deg_to_rad(randf_range(-spray_amount, spray_amount)))
		bullet_instance.rotate_z(deg_to_rad(randf_range(-spray_amount, spray_amount)))
	if (selected_fire_mode as GunBulletMode).ejecting_brass:
		instantiate_brass(eject_hole.global_position, eject_hole.global_transform.basis)

# ENERGY MODE

func spend_fuel(delta: float) -> void:
	gun_shot.emit()
	if !DebugCommands.full_ammo:
		var energy_spent = delta * (selected_fire_mode as GunEnergyMode).spend_amount 
		if share_ammo_and_energy:
			for fire_mode in fire_modes:
				if fire_mode is GunEnergyMode:
					(fire_mode as GunEnergyMode).energy -= energy_spent
					if (fire_mode as GunEnergyMode).energy < 0:
						(fire_mode as GunEnergyMode).energy = 0
		else:
			(selected_fire_mode as GunEnergyMode).energy -= energy_spent
			if (selected_fire_mode as GunEnergyMode).energy < 0:
				(selected_fire_mode as GunEnergyMode).energy = 0

func instantiate_hit(point: Vector3, normal: Vector3, _type: int) -> void:
	var hit_instance: Node3D
	hit_instance = (selected_fire_mode as GunEnergyMode).hit_decal.instantiate()
	get_tree().root.add_child(hit_instance)
	hit_instance.global_transform.origin = point
	TransformUtils.safe_look_at(hit_instance, point + normal)

func detect_raycast_collision(delta: float) -> void:
	if !is_shooting:
		return
	for raycast in (selected_fire_mode as GunEnergyMode).raycasts:
		if raycast.is_colliding() and can_damage:
			var collider: CollisionObject3D = raycast.get_collider()
			if collider.get_rid() == player_rid:
				return
			var point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			instantiate_hit(point, normal, collider.collision_layer)
			if collider.collision_layer == Definitions.SurfaceType.Hitbox:
				(collider as CharacterHitbox).damage_taken(selected_fire_mode.damage * delta, point, global_position)
			frames_elapsed = 0
			return

func vibrate_soft() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 1.0, 0.0, 0.1)

func vibrate_hard() -> void:
	if player_rid != GameManager.get_player_one().get_rid():
		return
	InputManager.vibrate_controller(0, 0.0, 1.0, 0.2)
