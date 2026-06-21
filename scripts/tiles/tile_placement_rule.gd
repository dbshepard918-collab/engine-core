class_name TilePlacementRule
extends Resource

enum RuleType { REQUIRED_NEIGHBOR, FORBIDDEN_NEIGHBOR, REQUIRED_SOCKET, MAX_PER_RADIUS, REQUIRES_NAV, REQUIRES_COLLISION, LIGHT_BUDGET }

@export var id: String
@export var rule_type: RuleType
@export var tile_id: String
@export var neighbor_direction: Vector3i = Vector3i.ZERO
@export var neighbor_tile_ids: Array[String] = []
@export var required_socket_tag: String = ""
@export var max_count: int = 1
@export var radius_cells: int = 4
@export var message: String = ""
