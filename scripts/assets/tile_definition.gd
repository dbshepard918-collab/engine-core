class_name TileDefinition
extends Resource

enum TileRole { FLOOR, WALL, CORNER, DOORWAY, STAIRS, BRIDGE, PROP, LANDMARK, ROOF, HAZARD }

@export var id: String
@export var display_name: String
@export var role: TileRole
@export var district_tags: Array[String] = []
@export var mesh_scene: PackedScene
@export var collision_scene: PackedScene
@export var nav_enabled: bool = true
@export var footprint: Vector2i = Vector2i(1, 1)
@export var connectors: Dictionary = {"north": false, "south": false, "east": false, "west": false}
@export var socket_tags: Array[String] = [] # neon_sign, loot, enemy_spawn, npc, vendor, door, cover
@export var weight: float = 1.0
@export var requires_story_flag: String = ""
@export var blocks_story_flag: String = ""

func can_connect(direction: String) -> bool:
    return bool(connectors.get(direction, false))
