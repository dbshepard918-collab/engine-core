class_name InventoryView
extends Control
@export var grid_container: GridContainer
@export var cell_scene: PackedScene
@export var item_icon_scene: PackedScene
@export var cell_size: Vector2 = Vector2(48, 48)
var model: InventoryGrid
var dragged_guid := ""
func bind_inventory(inv: InventoryGrid) -> void:
    model = inv; model.inventory_changed.connect(rebuild); rebuild()
func rebuild() -> void:
    for c in grid_container.get_children(): c.queue_free()
    grid_container.columns = model.columns
    for y in range(model.rows):
        for x in range(model.columns):
            var cell := cell_scene.instantiate() as Control; cell.custom_minimum_size = cell_size; cell.set_meta("x", x); cell.set_meta("y", y)
            cell.gui_input.connect(func(event): _on_cell_input(event, cell)); grid_container.add_child(cell)
    for guid in model.items.keys(): spawn_item_icon(guid)
func spawn_item_icon(guid: String) -> void:
    var rec = model.items[guid]
    var icon := item_icon_scene.instantiate() as TextureRect; icon.texture = rec.item.definition.icon
    icon.custom_minimum_size = Vector2(rec.item.definition.width, rec.item.definition.height) * cell_size; icon.set_meta("guid", guid)
    icon.gui_input.connect(func(event): _on_item_input(event, icon)); add_child(icon); icon.position = Vector2(rec.x, rec.y) * cell_size
func _on_item_input(event: InputEvent, icon: Control) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: dragged_guid = icon.get_meta("guid"); icon.modulate.a = 0.5
func _on_cell_input(event: InputEvent, cell: Control) -> void:
    if dragged_guid == "": return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
        var item = model.remove(dragged_guid)
        if item:
            var x := int(cell.get_meta("x")); var y := int(cell.get_meta("y"))
            if not model.place(item, x, y): model.add_auto(item)
        dragged_guid = ""

