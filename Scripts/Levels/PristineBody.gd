extends StaticBody3D
class_name PristineBody

signal damage

func damage_taken(amount: float):
	damage.emit(amount)
