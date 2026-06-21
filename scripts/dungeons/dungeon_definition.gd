class_name DungeonDefinition
extends Resource

enum DungeonTheme { LOWER_GRID_TUNNEL, CLINIC_BASEMENT, CORP_BLACKSITE, HOLO_SERVER, NEON_BELOW_CORE }
enum DungeonGoal { KILL_BOSS, RECOVER_OBJECT, CLEAR_STRONGHOLD, SURVIVE_EVENT, DESTROY_NODES }

@export var id: String
@export var display_name_key: String
@export var theme: DungeonTheme
@export var goal: DungeonGoal
@export var recommended_level_min: int = 1
@export var recommended_level_max: int = 15
@export var room_scene_pool: Array[PackedScene] = []
@export var corridor_scene_pool: Array[PackedScene] = []
@export var entrance_scene: PackedScene
@export var exit_scene: PackedScene
@export var boss_room_scene: PackedScene
@export var objective_scene_pool: Array[PackedScene] = []
@export var enemy_faction_ids: Array[String] = []
@export var min_rooms: int = 8
@export var max_rooms: int = 16
@export var branch_chance: float = 0.45
@export var loop_chance: float = 0.25
@export var side_event_count: int = 2
@export var reward_chest_scene: PackedScene
@export var seed_salt: int = 0
