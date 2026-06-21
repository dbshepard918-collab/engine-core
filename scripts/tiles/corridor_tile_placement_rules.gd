class_name CorridorTilePlacementRules
extends Resource

enum CorridorPolicy { STRICT, LENIENT, DEBUG_ONLY }

@export var policy: CorridorPolicy = CorridorPolicy.STRICT
@export var corridor_floor_ids: Array[String] = ["corridor_floor_4m", "floor_wet_asphalt_4m", "floor_metal_grate_4m"]
@export var doorway_ids: Array[String] = ["wall_doorway_4m"]
@export var wall_ids: Array[String] = ["wall_solid_neon_4m", "wall_pipe_cluster_4m", "wall_holo_ad_blank_4m"]
@export var intersection_ids: Array[String] = ["corridor_intersection_4m"]
@export var entrance_ids: Array[String] = ["dungeon_entrance_gate_4m", "stairs_down_4m"]
@export var max_dead_ends: int = 4
@export var min_corridor_length: int = 2
@export var require_wall_border: bool = true
@export var allow_single_tile_branches: bool = false
@export var require_doorway_at_room_transition: bool = true
