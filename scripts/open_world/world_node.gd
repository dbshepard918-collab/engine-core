class_name WorldNode
extends Resource

@export var grid: Vector2i
@export var world_position: Vector3
@export var tags: Array[String] = []
@export var occupied: bool = false
@export var poi_id: String = ""
@export var difficulty_bias: float = 0.0

func has_tag(tag: String) -> bool:
    return tags.has(tag)
