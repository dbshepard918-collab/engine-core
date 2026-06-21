class_name PropScatterProfile
extends Resource

@export var id: String
@export var prop_scenes: Array[PackedScene] = []
@export var required_socket_tag: String = "prop"
@export var max_per_tile: int = 4
@export var spawn_chance: float = 0.45
@export var random_yaw: bool = true
@export var scale_min: float = 0.9
@export var scale_max: float = 1.15
