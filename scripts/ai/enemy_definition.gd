class_name EnemyDefinition
extends Resource

enum Family { GANG, CORPORATE, DRONE, CYBER_MUTANT, NET_ENTITY, BOSS }
enum Role { SWARMER, BRUISER, RANGED, SNIPER, SUPPORT, SUMMONER, ELITE, BOSS }

@export var id: String
@export var display_name: String
@export var family: Family
@export var role: Role
@export var level: int = 1
@export var base_stats: StatBlock
@export var scene: PackedScene
@export var loot_table: LootTable
@export var abilities: Array[SkillDefinition] = []
@export var resist_profile: Dictionary = {}
@export var behavior_tags: Array[String] = []
@export_multiline var design_notes: String
