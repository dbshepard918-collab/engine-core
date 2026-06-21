class_name ItemDefinition
extends Resource

enum ItemType { WEAPON, ARMOR, IMPLANT, CONSUMABLE, CURRENCY, QUEST }
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, MYTHIC }

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var item_type: ItemType
@export var base_rarity: Rarity = Rarity.COMMON
@export var icon: Texture2D
@export var mesh_scene: PackedScene
@export var width: int = 1
@export var height: int = 1
@export var level_requirement: int = 1
@export var base_stats: StatBlock
@export var allowed_affix_groups: Array[String] = []
@export var unique_tags: Array[String] = []

func can_roll_affix_group(group_id: String) -> bool:
    return allowed_affix_groups.has(group_id)
