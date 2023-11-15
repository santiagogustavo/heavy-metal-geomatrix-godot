extends DirectionalLight3D

func _ready():
	GameManager.set_sun(self)

func _exit_tree():
	GameManager.remove_sun()
