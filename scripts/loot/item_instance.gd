class_name ItemInstance
extends Resource

@export var definition: ItemDefinition
@export var rarity: int
@export var item_level: int
@export var rolled_affixes: Array[Dictionary] = []
@export var rolled_stats: StatBlock
@export var stack_size: int = 1
@export var instance_guid: String = ""

func build_display_name() -> String:
    var prefix := ""
    match rarity:
        ItemDefinition.Rarity.COMMON: prefix = ""
        ItemDefinition.Rarity.UNCOMMON: prefix = "Augmented "
        ItemDefinition.Rarity.RARE: prefix = "Encrypted "
        ItemDefinition.Rarity.EPIC: prefix = "Prototype "
        ItemDefinition.Rarity.LEGENDARY: prefix = "Black-Ice "
        ItemDefinition.Rarity.MYTHIC: prefix = "Ghostline "
    return prefix + definition.display_name

func get_total_stats() -> StatBlock:
    var total := StatBlock.new()
    if definition.base_stats: total.add(definition.base_stats)
    if rolled_stats: total.add(rolled_stats)
    return total

