extends CharacterBody3D

@export var speed = 8.0
@export var acceleration = 12.0
@export var friction = 10.0

var vel = Vector3.ZERO

func _physics_process(delta):
	var input_vec = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)

	if input_vec.length() > 0:
		vel = vel.lerp(input_vec.normalized()*speed, acceleration*delta)
	else:
		vel = vel.lerp(Vector3.ZERO, friction*delta)

	velocity = vel
	move_and_slide()
