class_name DistrictDefinition
extends Resource

enum DistrictType { MARKET, UNDERPASS, CORPORATE_PLAZA, ROOFTOPS, DATA_CENTER, HOLO_CANYON, SEWER_GRID }

@export var id: String
@export var display_name_key: String
@export var district_type: DistrictType
@export var tile_sets: Array[PackedScene] = []
@export var landmark_scenes: Array[PackedScene] = []
@export var safe_room_scenes: Array[PackedScene] = []
@export var vendor_anchor_scenes: Array[PackedScene] = []
@export var enemy_faction_ids: Array[String] = []
@export var event_table: Array[Dictionary] = []
@export var target_room_count: int = 24
@export var max_combat_density: float = 1.0
@export var ambient_profile_id: String
@export var performance_budget_id: String
