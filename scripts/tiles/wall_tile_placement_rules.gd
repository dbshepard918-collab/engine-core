class_name WallTilePlacementRules
extends Resource

@export var solid_wall_ids: Array[String] = ["wall_solid_neon_4m", "wall_pipe_cluster_4m", "wall_holo_ad_blank_4m"]
@export var doorway_ids: Array[String] = ["wall_doorway_4m"]
@export var corner_inner_ids: Array[String] = ["wall_corner_inner_4m"]
@export var corner_outer_ids: Array[String] = ["wall_corner_outer_4m"]
@export var floor_ids: Array[String] = ["floor_plain_4m", "floor_wet_asphalt_4m", "floor_metal_grate_4m", "corridor_floor_4m"]
@export var forbidden_wall_touch_ids: Array[String] = ["hazard_electric_4m"]
@export var require_floor_inside_wall: bool = true
@export var allow_double_thick_walls: bool = false
@export var validate_corners: bool = true
@export var validate_doorways: bool = true
