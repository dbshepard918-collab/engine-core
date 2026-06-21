class_name InventoryGrid
extends Resource
signal inventory_changed
@export var columns: int = 10
@export var rows: int = 6
var cells: Array = []
var items: Dictionary = {}
func initialize() -> void:
    cells.clear(); cells.resize(columns * rows)
    for i in range(cells.size()): cells[i] = ""
func can_place(item: ItemInstance, x: int, y: int) -> bool:
    if item == null or item.definition == null or x < 0 or y < 0: return false
    if x + item.definition.width > columns or y + item.definition.height > rows: return false
    for yy in range(y, y + item.definition.height):
        for xx in range(x, x + item.definition.width):
            if cells[index(xx, yy)] != "": return false
    return true
func place(item: ItemInstance, x: int, y: int) -> bool:
    if not can_place(item, x, y): return false
    var guid := item.instance_guid; items[guid] = {"item": item, "x": x, "y": y}
    for yy in range(y, y + item.definition.height):
        for xx in range(x, x + item.definition.width): cells[index(xx, yy)] = guid
    inventory_changed.emit(); return true
func remove(guid: String) -> ItemInstance:
    if not items.has(guid): return null
    var rec = items[guid]; var item = rec.item as ItemInstance
    for yy in range(rec.y, rec.y + item.definition.height):
        for xx in range(rec.x, rec.x + item.definition.width): cells[index(xx, yy)] = ""
    items.erase(guid); inventory_changed.emit(); return item
func find_first_fit(item: ItemInstance) -> Vector2i:
    for y in range(rows):
        for x in range(columns):
            if can_place(item, x, y): return Vector2i(x, y)
    return Vector2i(-1, -1)
func add_auto(item: ItemInstance) -> bool:
    var pos := find_first_fit(item)
    return false if pos.x < 0 else place(item, pos.x, pos.y)
func index(x: int, y: int) -> int: return y * columns + x
