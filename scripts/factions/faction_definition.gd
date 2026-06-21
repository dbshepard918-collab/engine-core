class_name FactionDefinition
extends Resource

@export var id: String
@export var display_name_key: String
@export_multiline var description_key: String
@export var icon: Texture2D
@export var hostile_to_faction_ids: Array[String] = []
@export var allied_faction_ids: Array[String] = []
@export var rank_thresholds: Array[int] = [-100, -50, 0, 50, 100]
@export var rank_name_keys: Array[String] = ["Hated", "Hostile", "Neutral", "Trusted", "Allied"]
