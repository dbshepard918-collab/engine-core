class_name SkillTreeNodeDefinition
extends Resource

enum NodeType { ACTIVE_SKILL, PASSIVE_STAT, MODIFIER, KEYSTONE }

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var node_type: NodeType
@export var skill_id: String = ""
@export var max_rank: int = 1
@export var cost_per_rank: int = 1
@export var required_player_level: int = 1
@export var required_node_ids: Array[String] = []
@export var blocks_node_ids: Array[String] = []
@export var position: Vector2
@export var stat_bonus_per_rank: StatBlock
@export var modifier_tags: Array[String] = []
@export var branch: String = "chrome"

func is_active_skill() -> bool:
    return node_type == NodeType.ACTIVE_SKILL and skill_id != ""
