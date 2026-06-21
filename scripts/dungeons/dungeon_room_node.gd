class_name DungeonRoomNode
extends Resource

@export var id: String
@export var grid: Vector2i
@export var room_type: String = "normal" # entrance, normal, elite, event, objective, boss, treasure
@export var connections: Array[Vector2i] = []
@export var scene: PackedScene
@export var spawned: bool = false
