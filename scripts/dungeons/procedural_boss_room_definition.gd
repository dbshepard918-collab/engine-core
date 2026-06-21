class_name ProceduralBossRoomDefinition
extends Resource

enum BossRoomShape { CIRCLE, RECTANGLE, CROSS, DIAMOND, MULTI_PLATFORM, CORRIDOR_ARENA }
enum BossRoomPhaseStyle { SINGLE_PHASE, TWO_PHASE, THREE_PHASE, ADDS_PHASE, HAZARD_ROTATION }

@export var id: String
@export var display_name_key: String
@export var boss_encounter_id: String
@export var room_shape: BossRoomShape = BossRoomShape.CIRCLE
@export var phase_style: BossRoomPhaseStyle = BossRoomPhaseStyle.TWO_PHASE
@export var arena_radius_cells: int = 5
@export var arena_size_cells: Vector2i = Vector2i(11, 11)
@export var entrance_direction: Vector3i = Vector3i(0, 0, -1)
@export var exit_direction: Vector3i = Vector3i(0, 0, 1)
@export var floor_tile_ids: Array[String] = ["floor_wet_asphalt_4m"]
@export var wall_tile_ids: Array[String] = ["wall_solid_neon_4m"]
@export var doorway_tile_id: String = "wall_doorway_4m"
@export var hazard_tile_ids: Array[String] = []
@export var cover_tile_ids: Array[String] = []
@export var boss_spawn_scene: PackedScene
@export var reward_chest_scene: PackedScene
@export var lighting_zone_profile: Resource
@export var required_socket_tags: Array[String] = ["boss_spawn", "boss_gate", "reward"]
@export var add_spawn_count: int = 4
@export var hazard_node_count: int = 4
@export var lock_doors_on_start: bool = true
@export var unlock_exit_on_clear: bool = true
@export_multiline var design_notes: String
