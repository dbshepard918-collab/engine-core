class_name PlacementSocket
extends Marker3D

@export var socket_id: String
@export var tags: Array[String] = []
@export var weight: float = 1.0
@export var occupied: bool = false

func has_tag(tag: String) -> bool:
    return tags.has(tag)
