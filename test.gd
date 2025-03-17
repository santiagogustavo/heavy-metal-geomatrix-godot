extends Node3D

@onready var character_body: CharacterBody3D = $CharacterBody3D
@onready var navigation_agent: NavigationAgent3D = $CharacterBody3D/NavigationAgent3D
@onready var target: Node3D = $Target

func _ready() -> void:
	navigation_agent.link_reached.connect(func (details: Dictionary):
		character_body.global_position = details.link_exit_position
	)

func _physics_process(delta: float) -> void:
	navigation_agent.target_position = target.global_position
	var next_position: Vector3 = navigation_agent.get_next_path_position()
	var direction: Vector3 = character_body.global_position.direction_to(next_position)
	character_body.velocity = direction * 3
	character_body.move_and_slide()
