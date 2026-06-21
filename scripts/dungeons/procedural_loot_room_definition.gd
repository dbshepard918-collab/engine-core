class_name ProceduralLootRoomDefinition
extends Resource

enum LootRoomShape { SMALL_CACHE, VAULT, SIDE_LAB, BLACK_MARKET_CACHE, DATA_TREASURY, AMBUSH_CACHE }
enum LootRoomLockType { NONE, KEY, HACK, ELITE_GUARD, EVENT_CLEAR, BOSS_CLEAR }

@export var id: String
@export var display_name_key: String
@export var room_shape: LootRoomShape = LootRoomShape.SMALL_CACHE
@export var lock_type: LootRoomLockType = LootRoomLockType.NONE
@export var size_cells: Vector2i = Vector2i(5, 5)
@export var entrance_direction: Vector3i = Vector3i(0, 0, -1)
@export var floor_tile_ids: Array[String] = ["floor_wet_asphalt_4m"]
@export var wall_tile_ids: Array[String] = ["wall_solid_neon_4m"]
@export var doorway_tile_id: String = "wall_doorway_4m"
@export var loot_socket_count: int = 3
@export var rare_loot_socket_count: int = 1
@export var trap_socket_count: int = 0
@export var enemy_guard_socket_count: int = 0
@export var light_trigger_profile: Resource
@export var reward_chest_scene: PackedScene
@export var rare_reward_chest_scene: PackedScene
@export var hack_terminal_scene: PackedScene
@export var key_item_id: String = ""
@export var one_time_open: bool = true
@export_multiline var design_notes: String
