class_name CampaignActDefinition
extends Resource

@export var id: String
@export var title_key: String
@export_multiline var synopsis_key: String
@export var required_quest_ids: Array[String] = []
@export var unlock_quest_ids: Array[String] = []
@export var unlock_district_ids: Array[String] = []
@export var unlock_crafting_tiers: Array[int] = []
@export var primary_faction_ids: Array[String] = []
@export var boss_encounter_id: String
@export var recommended_level_min: int = 1
@export var recommended_level_max: int = 10
