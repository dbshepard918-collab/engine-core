class_name EquipmentComponent
extends Node
signal equipment_changed(total_stats: StatBlock)
@export var base_stats: StatBlock
var slots := {"weapon": null, "head": null, "torso": null, "legs": null, "implant_core": null, "implant_optic": null, "implant_neural": null, "trinket_1": null, "trinket_2": null}
func equip(slot: String, item: ItemInstance) -> ItemInstance:
    if not slots.has(slot): push_error("Unknown equipment slot: " + slot); return item
    var previous = slots[slot]; slots[slot] = item; equipment_changed.emit(calculate_total_stats()); return previous
func unequip(slot: String) -> ItemInstance:
    if not slots.has(slot): return null
    var previous = slots[slot]; slots[slot] = null; equipment_changed.emit(calculate_total_stats()); return previous
func calculate_total_stats() -> StatBlock:
    var total := base_stats.duplicate_block() if base_stats else StatBlock.new()
    for item in slots.values():
        if item != null: total.add(item.get_total_stats())
    return total

