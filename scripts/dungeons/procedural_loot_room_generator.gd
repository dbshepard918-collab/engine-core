class_name ProceduralLootRoomGenerator
extends Node3D

signal loot_room_generated(room_id: String)
signal loot_room_opened(room_id: String)
signal loot_room_looted(room_id: String)

@export var definition: ProceduralLootRoomDefinition
@export var gridmap: GridMap
@export var tile_item_lookup: Dictionary = {}
@export var socket_container: Node3D
@export var prop_container: Node3D
@export var lighting_trigger_container: Node3D
@export var seed_value: int = 0

var rng := RandomNumberGenerator.new()
var opened := false
var looted := false

func generate(center: Vector3i = Vector3i.ZERO) -> void:
    if definition == null or gridmap == null or gridmap.mesh_library == null:
        push_error("Loot room generator missing definition, GridMap, or MeshLibrary.")
        return
    rng.seed = seed_value if seed_value != 0 else hash(definition.id)
    clear_area(center)
    paint_floor(center)
    paint_walls(center)
    paint_entrance(center)
    create_loot_sockets(center)
    create_optional_lock_or_guards(center)
    create_lighting_trigger(center)
    loot_room_generated.emit(definition.id)

func clear_area(center: Vector3i) -> void:
    var half := get_half_size()
    for z in range(center.z - half.y - 1, center.z + half.y + 2):
        for x in range(center.x - half.x - 1, center.x + half.x + 2):
            gridmap.set_cell_item(Vector3i(x, center.y, z), GridMap.INVALID_CELL_ITEM)
    if socket_container:
        for c in socket_container.get_children(): c.queue_free()

func get_half_size() -> Vector2i:
    return Vector2i(max(1, int(definition.size_cells.x / 2)), max(1, int(definition.size_cells.y / 2)))

func paint_floor(center: Vector3i) -> void:
    var half := get_half_size()
    for z in range(-half.y, half.y + 1):
        for x in range(-half.x, half.x + 1):
            set_tile(center + Vector3i(x, 0, z), pick(definition.floor_tile_ids))

func paint_walls(center: Vector3i) -> void:
    var half := get_half_size()
    for x in range(-half.x - 1, half.x + 2):
        set_tile(center + Vector3i(x, 0, -half.y - 1), pick(definition.wall_tile_ids))
        set_tile(center + Vector3i(x, 0, half.y + 1), pick(definition.wall_tile_ids))
    for z in range(-half.y, half.y + 1):
        set_tile(center + Vector3i(-half.x - 1, 0, z), pick(definition.wall_tile_ids))
        set_tile(center + Vector3i(half.x + 1, 0, z), pick(definition.wall_tile_ids))

func paint_entrance(center: Vector3i) -> void:
    var half := get_half_size()
    var entrance := center + definition.entrance_direction * Vector3i(half.x + 1, 0, half.y + 1)
    set_tile(entrance, definition.doorway_tile_id)
    var approach := entrance + definition.entrance_direction
    set_tile(approach, pick(definition.floor_tile_ids))

func create_loot_sockets(center: Vector3i) -> void:
    if socket_container == null: return
    for i in range(definition.loot_socket_count):
        create_socket("SOCKET_loot_%02d" % i, ["loot", "loot_common"], gridmap.to_global(gridmap.map_to_local(random_inside_cell(center))))
    for i in range(definition.rare_loot_socket_count):
        create_socket("SOCKET_rare_loot_%02d" % i, ["loot", "loot_rare"], gridmap.to_global(gridmap.map_to_local(random_inside_cell(center))))
    for i in range(definition.trap_socket_count):
        create_socket("SOCKET_trap_%02d" % i, ["trap", "loot_room_trap"], gridmap.to_global(gridmap.map_to_local(random_inside_cell(center))))

func create_optional_lock_or_guards(center: Vector3i) -> void:
    if socket_container == null: return
    if definition.lock_type == ProceduralLootRoomDefinition.LootRoomLockType.HACK:
        create_socket("SOCKET_hack_terminal", ["hack_terminal", "lock"], gridmap.to_global(gridmap.map_to_local(center + Vector3i(1, 0, 0))))
    if definition.enemy_guard_socket_count > 0:
        for i in range(definition.enemy_guard_socket_count):
            create_socket("SOCKET_loot_guard_%02d" % i, ["enemy_spawn", "loot_guard"], gridmap.to_global(gridmap.map_to_local(random_inside_cell(center))))

func create_lighting_trigger(center: Vector3i) -> void:
    if definition.light_trigger_profile == null or lighting_trigger_container == null: return
    var trigger := LightingTrigger.new()
    trigger.name = "LootLightingTrigger_" + definition.id
    trigger.profile = definition.light_trigger_profile
    lighting_trigger_container.add_child(trigger)
    trigger.global_position = gridmap.to_global(gridmap.map_to_local(center))
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    var half := get_half_size()
    box.size = Vector3((half.x + 1) * gridmap.cell_size.x, 4.0, (half.y + 1) * gridmap.cell_size.z)
    shape.shape = box
    trigger.add_child(shape)

func create_socket(name: String, tags: Array[String], pos: Vector3) -> void:
    var s := PlacementSocket.new()
    s.name = name
    s.socket_id = name
    s.tags = tags
    socket_container.add_child(s)
    s.global_position = pos
    s.add_to_group("placement_sockets")

func random_inside_cell(center: Vector3i) -> Vector3i:
    var half := get_half_size()
    return center + Vector3i(rng.randi_range(-half.x + 1, half.x - 1), 0, rng.randi_range(-half.y + 1, half.y - 1))

func set_tile(cell: Vector3i, tile_id: String) -> void:
    var item := resolve_item(tile_id)
    if item >= 0: gridmap.set_cell_item(cell, item)

func resolve_item(tile_id: String) -> int:
    if tile_item_lookup.has(tile_id): return int(tile_item_lookup[tile_id])
    return gridmap.mesh_library.find_item_by_name(tile_id)

func pick(ids: Array[String]) -> String:
    if ids.is_empty(): return ""
    return ids[rng.randi_range(0, ids.size() - 1)]

func open_room() -> void:
    opened = true
    loot_room_opened.emit(definition.id)

func mark_looted() -> void:
    looted = true
    loot_room_looted.emit(definition.id)
