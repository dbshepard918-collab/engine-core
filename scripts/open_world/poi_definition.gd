class_name POIDefinition
extends Resource

enum POIType { TOWN_HUB, SAFEHOUSE, WORLD_EVENT, ELITE_PATROL, VENDOR, CRAFTING, FAST_TRAVEL, DUNGEON_ENTRANCE, STRONGHOLD, BOSS_GATE, LORE, RESOURCE_NODE }

@export var id: String
@export var display_name_key: String
@export var poi_type: POIType
@export var scene: PackedScene
@export var icon: Texture2D
@export var min_level: int = 1
@export var max_level: int = 50
@export var faction_id: String = ""
@export var required_story_flag: String = ""
@export var blocks_story_flag: String = ""
@export var weight: float = 1.0
@export var min_distance_from_same_type: float = 80.0
@export var reveal_radius: float = 36.0
@export var can_be_fast_travel_target: bool = false
@export var attached_dungeon_id: String = ""
@export_multiline var generation_notes: String
