extends Node

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")
	print("Game Initialized")
