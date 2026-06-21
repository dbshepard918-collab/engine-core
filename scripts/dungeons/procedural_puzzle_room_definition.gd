class_name ProceduralPuzzleRoomDefinition
extends Resource

enum PuzzleRoomType { SWITCH_SEQUENCE, PRESSURE_PLATES, LASER_GRID, POWER_ROUTING, HACK_NODES, TIMED_LOCKDOWN }
enum PuzzleRewardGate { NONE, SIDE_LOOT, MAIN_PATH, BOSS_KEY, FACTION_CACHE }

@export var id: String
@export var display_name_key: String
@export var puzzle_type: PuzzleRoomType = PuzzleRoomType.SWITCH_SEQUENCE
@export var reward_gate: PuzzleRewardGate = PuzzleRewardGate.SIDE_LOOT
@export var size_cells: Vector2i = Vector2i(9, 7)
@export var entrance_direction: Vector3i = Vector3i(0, 0, -1)
@export var exit_direction: Vector3i = Vector3i(0, 0, 1)
@export var floor_tile_ids: Array[String] = ["floor_wet_asphalt_4m"]
@export var wall_tile_ids: Array[String] = ["wall_solid_neon_4m"]
@export var doorway_tile_id: String = "wall_doorway_4m"
@export var puzzle_device_scene_pool: Array[PackedScene] = []
@export var reward_scene: PackedScene
@export var switch_count: int = 3
@export var pressure_plate_count: int = 3
@export var hazard_tile_ids: Array[String] = []
@export var lighting_zone_profile: Resource
@export var solve_lighting_zone_profile: Resource
@export var allow_combat_ambush: bool = false
@export var enemy_spawn_count: int = 0
@export var one_time_solve: bool = true
@export_multiline var design_notes: String
