extends Node
const SAVE_PATH := "user://save_slot_01.json"
func save_game(player: Node, inventory: InventoryGrid, equipment: EquipmentComponent) -> void:
    var data := {"version": 1, "player": {"position": var_to_str(player.global_position), "level": player.get("level") if "level" in player else 1, "xp": player.get("xp") if "xp" in player else 0}, "inventory": serialize_inventory(inventory), "equipment": serialize_equipment(equipment)}
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE); f.store_string(JSON.stringify(data, "  "))
func load_game() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH): return {}
    var f := FileAccess.open(SAVE_PATH, FileAccess.READ); var parsed = JSON.parse_string(f.get_as_text())
    return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
func serialize_inventory(inv: InventoryGrid) -> Array:
    var out := []
    for guid in inv.items.keys():
        var rec = inv.items[guid]
        out.append({"guid": guid, "item_id": rec.item.definition.id, "rarity": rec.item.rarity, "item_level": rec.item.item_level, "affixes": rec.item.rolled_affixes, "x": rec.x, "y": rec.y})
    return out
func serialize_equipment(eq: EquipmentComponent) -> Dictionary:
    var out := {}
    for slot in eq.slots.keys():
        var item = eq.slots[slot]; out[slot] = item.instance_guid if item != null else ""
    return out

