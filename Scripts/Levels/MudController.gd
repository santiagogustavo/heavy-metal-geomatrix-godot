extends ExtendedArea3D

@onready var decal: Decal = $Decal
@export_range(0.0, 60000.0) var lifetime: float = 60000.0

var time_elapsed: float = 0.0

func _ready() -> void:
	hit.connect(handle_hitbox_mud_splash)

func _process(delta: float) -> void:
	is_attacking = true
	can_hit = true
	if !decal:
		return
	if time_elapsed < lifetime:
		time_elapsed += delta
		var ratio = time_elapsed / lifetime
		decal.modulate.a = lerpf(decal.modulate.a, 0.0, ratio)

func handle_hitbox_mud_splash(body: Node3D, _point: Vector3, _normal: Vector3) -> void:
	var decal_instance = decal.duplicate()
	decal_instance.visible = true
	body.add_child(decal_instance)
