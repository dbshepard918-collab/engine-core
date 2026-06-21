class_name QuestDefinition
extends Resource

enum QuestType { MAIN, SIDE, CONTRACT, TUTORIAL, WORLD_EVENT }

@export var id: String
@export var title: String
@export_multiline var summary: String
@export var quest_type: QuestType
@export var giver_npc_id: String
@export var recommended_level: int = 1
@export var prerequisite_quest_ids: Array[String] = []
@export var steps: Array[QuestStepDefinition] = []
@export var reward_xp: int = 0
@export var reward_currency: int = 0
@export var reward_item_ids: Array[String] = []
@export var followup_quest_ids: Array[String] = []
