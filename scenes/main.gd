extends Node3D

func _ready():
	print("Main Scene Loaded")

func _process(delta):
	if Input.is_key_pressed(KEY_F1):
		print("Debug key pressed")
