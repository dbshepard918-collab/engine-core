class_name ProceduralDungeonEntranceDefinition
extends Resource

enum EntranceRole { MAIN_STORY, SIDE_DUNGEON, STRONGHOLD_EXIT, EVENT_PORTAL, BOSS_GATE }
enum EntranceShape { STAIRWELL, ELEVATOR, SERVICE_HATCH, SERVER_PORTAL, TRANSIT_GATE, SEWER_GRATE }

@export var id: String
@export var display_name_key: String
@export var entrance_role: EntranceRole = EntranceRole.SIDE_DUNGEON
@export var entrance_shape: EntranceShape = EntranceShape.STAIRWELL
@export var scene: PackedScene
@export var dungeon_definition: DungeonDefinition
@export var required_campaign_flag: String = ""
@export var required_faction_id: String = ""
@export var required_faction_rank: int = 0
@export var min_player_level: int = 1
@export var map_icon: Texture2D
@export var light_profile: Resource
@export var socket_tag: String = "dungeon_side"
@export var reveal_on_region_enter: bool = false
@export var one_time_clear: bool = false
@export var procedural_seed_offset: int = 0
@export_multiline var placement_notes: String

func get_dungeon_id() -> String:
    return dungeon_definition.id if dungeon_definition else ""
