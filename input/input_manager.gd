extends Node

func get_movement_vector():
	return Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)

func is_attack_pressed():
	return Input.is_action_just_pressed("primary_attack")
