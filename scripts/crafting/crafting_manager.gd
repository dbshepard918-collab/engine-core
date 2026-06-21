extends Node

signal craft_succeeded(recipe_id: String, result)
signal craft_failed(recipe_id: String, reason: String)

@export var recipes: Array[CraftingRecipeDefinition] = []
@export var wallet: MaterialWallet
@export var inventory: InventoryGrid
@export var loot_generator: LootGenerator
@export var campaign_state: CampaignState
@export var faction_manager: FactionManager

var recipes_by_id := {}
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    for r in recipes: recipes_by_id[r.id] = r

func can_craft(recipe_id: String, target_item: ItemInstance = null) -> bool:
    var r: CraftingRecipeDefinition = recipes_by_id.get(recipe_id)
    if r == null: return false
    if not campaign_state.unlocked_crafting_tiers.has(r.required_crafting_tier): return false
    if r.required_faction_id != "" and faction_manager.get_rank(r.required_faction_id) < r.required_faction_rank: return false
    if not wallet.has_materials(r.input_materials): return false
    if not wallet.can_pay(r.currency_cost): return false
    if target_item and not is_item_allowed(r, target_item): return false
    return true

func craft(recipe_id: String, target_item: ItemInstance = null) -> bool:
    var r: CraftingRecipeDefinition = recipes_by_id.get(recipe_id)
    if r == null:
        craft_failed.emit(recipe_id, "Unknown recipe")
        return false
    if not can_craft(recipe_id, target_item):
        craft_failed.emit(recipe_id, "Requirements not met")
        return false
    wallet.consume_materials(r.input_materials)
    wallet.pay(r.currency_cost)
    if rng.randf() > r.success_chance:
        craft_failed.emit(recipe_id, "Crafting failed")
        return false
    var result = execute_recipe(r, target_item)
    craft_succeeded.emit(recipe_id, result)
    return true

func execute_recipe(r: CraftingRecipeDefinition, target_item: ItemInstance):
    match r.recipe_type:
        CraftingRecipeDefinition.RecipeType.CREATE_ITEM:
            var def := GameDatabase.get_item(r.output_item_id)
            var item := loot_generator.roll_item_instance(def, max(1, target_item.item_level if target_item else 1), 0.0)
            inventory.add_auto(item)
            return item
        CraftingRecipeDefinition.RecipeType.UPGRADE_RARITY:
            target_item.rarity = min(target_item.rarity + 1, ItemDefinition.Rarity.MYTHIC)
            return target_item
        CraftingRecipeDefinition.RecipeType.REROLL_AFFIX:
            target_item.rolled_affixes.clear()
            var rerolled := loot_generator.roll_item_instance(target_item.definition, target_item.item_level, 0.0)
            target_item.rolled_affixes = rerolled.rolled_affixes
            target_item.rolled_stats = rerolled.rolled_stats
            return target_item
        CraftingRecipeDefinition.RecipeType.CONVERT_MATERIAL:
            for id in r.output_materials.keys(): wallet.add_material(id, int(r.output_materials[id]))
            return r.output_materials
    return null

func is_item_allowed(r: CraftingRecipeDefinition, item: ItemInstance) -> bool:
    if item == null: return r.recipe_type == CraftingRecipeDefinition.RecipeType.CREATE_ITEM
    if not r.allowed_item_types.is_empty() and not r.allowed_item_types.has(item.definition.item_type): return false
    if not r.allowed_rarities.is_empty() and not r.allowed_rarities.has(item.rarity): return false
    return true
