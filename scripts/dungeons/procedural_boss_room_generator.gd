class_name ProceduralBossRoomGenerator
extends Node3D

signal boss_room_generated(room_id: String)
signal boss_room_started(room_id: String)
signal boss_room_cleared(room_id: String)

@export var definition: ProceduralBossRoomDefinition
@export var gridmap: GridMap
@export var tile_item_lookup: Dictionary = {} # tile_id -> MeshLibrary item id override
@export var socket_container: Node3D
@export var encounter_container: Node3D
@export var lighting_zone_container: Node3D
@export var seed_value: int = 0

var rng := RandomNumberGenerator.new()
var boss_spawn_position := Vector3.ZERO
var clear_state := false

func generate(center: Vector3i = Vector3i.ZERO) -> void:
    if definition == null or gridmap == null or gridmap.mesh_library == null:
        push_error("Boss room generator missing definition, GridMap, or MeshLibrary.")
        return
    rng.seed = seed_value if seed_value != 0 else hash(definition.id)
    clear_previous(center)
    paint_floor(center)
    paint_walls(center)
    paint_entrance_exit(center)
    place_hazards_and_cover(center)
    create_required_sockets(center)
    spawn_lighting_zone(center)
    boss_room_generated.emit(definition.id)

func clear_previous(center: Vector3i) -> void:
    var half := get_half_size()
    for z in range(center.z - half.y - 2, center.z + half.y + 3):
        for x in range(center.x - half.x - 2, center.x + half.x + 3):
            gridmap.set_cell_item(Vector3i(x, center.y, z), GridMap.INVALID_CELL_ITEM)
    if socket_container:
        for c in socket_container.get_children(): c.queue_free()

func get_half_size() -> Vector2i:
    if definition.room_shape == ProceduralBossRoomDefinition.BossRoomShape.CIRCLE:
        return Vector2i(definition.arena_radius_cells, definition.arena_radius_cells)
    return Vector2i(int(definition.arena_size_cells.x / 2), int(definition.arena_size_cells.y / 2))

func paint_floor(center: Vector3i) -> void:
    var half := get_half_size()
    for z in range(-half.y, half.y + 1):
        for x in range(-half.x, half.x + 1):
            if is_inside_shape(Vector2i(x, z)):
                set_tile(center + Vector3i(x, 0, z), pick(definition.floor_tile_ids))

func paint_walls(center: Vector3i) -> void:
    var half := get_half_size()
    for z in range(-half.y - 1, half.y + 2):
        for x in range(-half.x - 1, half.x + 2):
            var p := Vector2i(x, z)
            if not is_inside_shape(p) and touches_inside(p):
                set_tile(center + Vector3i(x, 0, z), pick(definition.wall_tile_ids))

func paint_entrance_exit(center: Vector3i) -> void:
    var half := get_half_size()
    var entrance := center + definition.entrance_direction * Vector3i(half.x + 1, 0, half.y + 1)
    var exit := center + definition.exit_direction * Vector3i(half.x + 1, 0, half.y + 1)
    set_tile(entrance, definition.doorway_tile_id)
    set_tile(exit, definition.doorway_tile_id)

func place_hazards_and_cover(center: Vector3i) -> void:
    for i in range(definition.hazard_node_count):
        if definition.hazard_tile_ids.is_empty(): break
        var p := random_inside_cell(center)
        set_tile(p, pick(definition.hazard_tile_ids))
    for i in range(max(0, definition.add_spawn_count - 2)):
        if definition.cover_tile_ids.is_empty(): break
        var p := random_inside_cell(center)
        set_tile(p, pick(definition.cover_tile_ids))

func create_required_sockets(center: Vector3i) -> void:
    if socket_container == null: return
    create_socket("SOCKET_boss_spawn", ["boss_spawn"], gridmap.to_global(gridmap.map_to_local(center)))
    create_socket("SOCKET_reward", ["reward"], gridmap.to_global(gridmap.map_to_local(center + definition.exit_direction * 2)))
    for i in range(definition.add_spawn_count):
        var p := random_inside_cell(center)
        create_socket("SOCKET_boss_add_%02d" % i, ["enemy_spawn", "boss_add"], gridmap.to_global(gridmap.map_to_local(p)))

func create_socket(name: String, tags: Array[String], pos: Vector3) -> void:
    var s := PlacementSocket.new()
    s.name = name
    s.socket_id = name
    s.tags = tags
    socket_container.add_child(s)
    s.global_position = pos
    s.add_to_group("placement_sockets")

func spawn_lighting_zone(center: Vector3i) -> void:
    if definition.lighting_zone_profile == null or lighting_zone_container == null: return
    var zone := DynamicLightingZone.new()
    zone.name = "BossLightingZone_" + definition.id
    zone.profile = definition.lighting_zone_profile
    lighting_zone_container.add_child(zone)
    zone.global_position = gridmap.to_global(gridmap.map_to_local(center))
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    var half := get_half_size()
    box.size = Vector3((half.x + 2) * gridmap.cell_size.x, 4.0, (half.y + 2) * gridmap.cell_size.z)
    shape.shape = box
    zone.add_child(shape)

func is_inside_shape(p: Vector2i) -> bool:
    match definition.room_shape:
        ProceduralBossRoomDefinition.BossRoomShape.CIRCLE:
            return Vector2(p.x, p.y).length() <= float(definition.arena_radius_cells)
        ProceduralBossRoomDefinition.BossRoomShape.DIAMOND:
            return abs(p.x) + abs(p.y) <= definition.arena_radius_cells
        ProceduralBossRoomDefinition.BossRoomShape.CROSS:
            return abs(p.x) <= 2 or abs(p.y) <= 2
        _:
            var half := get_half_size()
            return abs(p.x) <= half.x and abs(p.y) <= half.y

func touches_inside(p: Vector2i) -> bool:
    for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
        if is_inside_shape(p + d): return true
    return false

func random_inside_cell(center: Vector3i) -> Vector3i:
    var half := get_half_size()
    for attempt in range(100):
        var p := Vector2i(rng.randi_range(-half.x + 1, half.x - 1), rng.randi_range(-half.y + 1, half.y - 1))
        if is_inside_shape(p): return center + Vector3i(p.x, 0, p.y)
    return center

func set_tile(cell: Vector3i, tile_id: String) -> void:
    var item := resolve_item(tile_id)
    if item >= 0: gridmap.set_cell_item(cell, item)

func resolve_item(tile_id: String) -> int:
    if tile_item_lookup.has(tile_id): return int(tile_item_lookup[tile_id])
    return gridmap.mesh_library.find_item_by_name(tile_id)

func pick(ids: Array[String]) -> String:
    if ids.is_empty(): return ""
    return ids[rng.randi_range(0, ids.size() - 1)]

func begin_encounter() -> void:
    boss_room_started.emit(definition.id)

func clear_encounter() -> void:
    clear_state = true
    boss_room_cleared.emit(definition.id)
