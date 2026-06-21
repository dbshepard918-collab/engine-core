class_name CraftingRecipeDefinition
extends Resource

enum RecipeType { CREATE_ITEM, UPGRADE_RARITY, REROLL_AFFIX, ADD_SOCKET, MODIFY_IMPLANT, CONVERT_MATERIAL }

@export var id: String
@export var display_name_key: String
@export var recipe_type: RecipeType
@export var required_crafting_tier: int = 1
@export var required_faction_id: String = ""
@export var required_faction_rank: int = 0
@export var input_items: Array[String] = []
@export var input_materials: Dictionary = {} # material_id -> count
@export var currency_cost: int = 0
@export var output_item_id: String = ""
@export var output_materials: Dictionary = {}
@export var allowed_item_types: Array[int] = []
@export var allowed_rarities: Array[int] = []
@export var success_chance: float = 1.0
@export var affix_group_pool: Array[String] = []
