class_name LootGenerator
extends Node
@export var affix_pool: Array[AffixDefinition] = []
@export var rarity_weights := { ItemDefinition.Rarity.COMMON: 60.0, ItemDefinition.Rarity.UNCOMMON: 25.0, ItemDefinition.Rarity.RARE: 10.0, ItemDefinition.Rarity.EPIC: 4.0, ItemDefinition.Rarity.LEGENDARY: 0.9, ItemDefinition.Rarity.MYTHIC: 0.1 }
var rng := RandomNumberGenerator.new()
func _ready() -> void: rng.randomize()
func roll_table(table: LootTable, monster_level: int, magic_find: float = 0.0) -> Array[ItemInstance]:
    var drops: Array[ItemInstance] = []
    if rng.randf() > table.drop_chance: return drops
    var item_def := roll_item_definition(table, monster_level)
    if item_def: drops.append(roll_item_instance(item_def, monster_level, magic_find))
    return drops
func roll_item_definition(table: LootTable, level: int) -> ItemDefinition:
    var valid := []; var total := 0.0
    for e in table.entries:
        if level >= int(e.get("min_level", 1)) and level <= int(e.get("max_level", 999)):
            valid.append(e); total += float(e.get("weight", 1.0))
    if valid.is_empty(): return null
    var roll := rng.randf_range(0.0, total); var running := 0.0
    for e in valid:
        running += float(e.get("weight", 1.0))
        if roll <= running: return GameDatabase.get_item(str(e.get("item_id", "")))
    return null
func roll_item_instance(def: ItemDefinition, item_level: int, magic_find: float = 0.0) -> ItemInstance:
    var inst = ItemInstance.new(); inst.definition = def; inst.item_level = item_level; inst.rarity = roll_rarity(magic_find); inst.instance_guid = generate_guid(); inst.rolled_stats = StatBlock.new()
    var used_groups := {}
    for i in range(get_affix_count(inst.rarity)):
        var affix := roll_affix_for_item(def, item_level, inst.rarity, used_groups)
        if affix == null: continue
        used_groups[affix.group_id] = true
        var rolled := affix.roll(rng); inst.rolled_affixes.append(rolled)
        if rolled.stat_name in inst.rolled_stats: inst.rolled_stats.set(rolled.stat_name, inst.rolled_stats.get(rolled.stat_name) + float(rolled.value))
    return inst
func roll_rarity(magic_find: float) -> int:
    var adjusted := rarity_weights.duplicate()
    adjusted[ItemDefinition.Rarity.RARE] += magic_find * 0.5; adjusted[ItemDefinition.Rarity.EPIC] += magic_find * 0.2; adjusted[ItemDefinition.Rarity.LEGENDARY] += magic_find * 0.05
    var total := 0.0
    for v in adjusted.values(): total += float(v)
    var roll := rng.randf_range(0.0, total); var running := 0.0
    for rarity in adjusted.keys():
        running += adjusted[rarity]
        if roll <= running: return rarity
    return ItemDefinition.Rarity.COMMON
func get_affix_count(rarity: int) -> int:
    match rarity:
        ItemDefinition.Rarity.COMMON: return 0
        ItemDefinition.Rarity.UNCOMMON: return 1
        ItemDefinition.Rarity.RARE: return rng.randi_range(2, 3)
        ItemDefinition.Rarity.EPIC: return rng.randi_range(3, 4)
        ItemDefinition.Rarity.LEGENDARY: return rng.randi_range(4, 5)
        ItemDefinition.Rarity.MYTHIC: return 6
    return 0
func roll_affix_for_item(def: ItemDefinition, level: int, rarity: int, used_groups: Dictionary) -> AffixDefinition:
    var valid: Array[AffixDefinition] = []; var total := 0.0
    for a in affix_pool:
        if used_groups.has(a.group_id) or not def.can_roll_affix_group(a.group_id) or level < a.min_item_level: continue
        if not a.rarities.is_empty() and not a.rarities.has(rarity): continue
        valid.append(a); total += a.weight
    if valid.is_empty(): return null
    var roll := rng.randf_range(0.0, total); var running := 0.0
    for a in valid:
        running += a.weight
        if roll <= running: return a
    return null
func generate_guid() -> String: return "%08x-%08x-%08x" % [rng.randi(), rng.randi(), rng.randi()]

