class_name StaircaseTilePlacementRules
extends Resource

enum StairPolicy { STRICT, LENIENT, DEBUG_ONLY }

@export var policy: StairPolicy = StairPolicy.STRICT
@export var stair_up_ids: Array[String] = ["stairs_up_4m"]
@export var stair_down_ids: Array[String] = ["stairs_down_4m"]
@export var landing_ids: Array[String] = ["stair_landing_4m", "floor_wet_asphalt_4m", "corridor_floor_4m"]
@export var corridor_ids: Array[String] = ["corridor_floor_4m", "floor_wet_asphalt_4m"]
@export var blocked_ids: Array[String] = ["wall_solid_neon_4m", "wall_pipe_cluster_4m"]
@export var require_landing_top_bottom: bool = true
@export var require_clear_forward_cell: bool = true
@export var require_direction_pair: bool = true
@export var max_stairs_per_room: int = 2
@export var allowed_y_delta: int = 1
