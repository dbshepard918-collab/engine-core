class_name WorldRegionDefinition
extends Resource

enum RegionType { RAINMARKET, LOWER_GRID, HELIX_PLAZA, HOLO_CANYON, NEON_BELOW, BADLAND_EDGE }

@export var id: String
@export var display_name_key: String
@export var region_type: RegionType
@export var world_size_cells: Vector2i = Vector2i(64, 64)
@export var cell_size: float = 16.0
@export var recommended_level_min: int = 1
@export var recommended_level_max: int = 15
@export var biome_tags: Array[String] = []
@export var primary_faction_ids: Array[String] = []
@export var tile_scene_pool: Array[PackedScene] = []
@export var road_scene_pool: Array[PackedScene] = []
@export var boundary_scene_pool: Array[PackedScene] = []
@export var poi_pool: Array[POIDefinition] = []
@export var dungeon_pool: Array[Resource] = []
@export var min_poi_count: int = 12
@export var max_poi_count: int = 24
@export var dungeon_entrance_count: int = 4
@export var stronghold_count: int = 1
@export var world_event_count: int = 3
@export var seed_salt: int = 0
