class_name ProceduralPuzzleRoomGenerator
extends Node3D

signal puzzle_room_generated(room_id: String)
signal puzzle_room_started(room_id: String)
signal puzzle_room_solved(room_id: String)

@export var definition: ProceduralPuzzleRoomDefinition
@export var gridmap: GridMap
@export var tile_item_lookup: Dictionary = {}
@export var socket_container: Node3D
@export var prop_container: Node3D
@export var lighting_zone_container: Node3D
@export var seed_value: int = 0

var rng := RandomNumberGenerator.new()
var solved := false
var required_inputs := []
var activated_inputs := []

func generate(center: Vector3i = Vector3i.ZERO) -> void:
    if definition == null or gridmap == null or gridmap.mesh_library == null:
        push_error("Puzzle room generator missing definition, GridMap, or MeshLibrary.")
        return
    rng.seed = seed_value if seed_value != 0 else hash(definition.id)
    clear_area(center)
    paint_floor(center)
    paint_walls(center)
    paint_entrance_exit(center)
    place_hazards(center)
    create_puzzle_sockets(center)
    create_reward_and_enemy_sockets(center)
    create_lighting_zones(center)
    build_required_input_sequence()
    puzzle_room_generated.emit(definition.id)

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

func paint_entrance_exit(center: Vector3i) -> void:
    var half := get_half_size()
    var entrance := center + definition.entrance_direction * Vector3i(half.x + 1, 0, half.y + 1)
    var exit := center + definition.exit_direction * Vector3i(half.x + 1, 0, half.y + 1)
    set_tile(entrance, definition.doorway_tile_id)
    set_tile(exit, definition.doorway_tile_id)

func place_hazards(center: Vector3i) -> void:
    if definition.hazard_tile_ids.is_empty(): return
    var count: int = max(1, int((definition.size_cells.x + definition.size_cells.y) / 4))
    for i in range(count):
        set_tile(random_inside_cell(center), pick(definition.hazard_tile_ids))

func create_puzzle_sockets(center: Vector3i) -> void:
    if socket_container == null: return
    match definition.puzzle_type:
        ProceduralPuzzleRoomDefinition.PuzzleRoomType.PRESSURE_PLATES:
            for i in range(definition.pressure_plate_count):
                create_socket("SOCKET_pressure_plate_%02d" % i, ["puzzle", "pressure_plate"], random_inside_world(center))
        ProceduralPuzzleRoomDefinition.PuzzleRoomType.HACK_NODES:
            for i in range(definition.switch_count):
                create_socket("SOCKET_hack_node_%02d" % i, ["puzzle", "hack_node"], random_inside_world(center))
        _:
            for i in range(definition.switch_count):
                create_socket("SOCKET_switch_%02d" % i, ["puzzle", "switch"], random_inside_world(center))

func create_reward_and_enemy_sockets(center: Vector3i) -> void:
    create_socket("SOCKET_puzzle_reward", ["reward", "puzzle_reward"], gridmap.to_global(gridmap.map_to_local(center + definition.exit_direction * 2)))
    if definition.allow_combat_ambush:
        for i in range(definition.enemy_spawn_count):
            create_socket("SOCKET_puzzle_enemy_%02d" % i, ["enemy_spawn", "puzzle_ambush"], random_inside_world(center))

func create_lighting_zones(center: Vector3i) -> void:
    if lighting_zone_container == null: return
    if definition.lighting_zone_profile:
        spawn_zone("PuzzleLightingZone_" + definition.id, definition.lighting_zone_profile, center)
    if definition.solve_lighting_zone_profile:
        spawn_zone("PuzzleSolvedLightingZone_" + definition.id, definition.solve_lighting_zone_profile, center)

func spawn_zone(name: String, profile: Resource, center: Vector3i) -> void:
    var zone := DynamicLightingZone.new()
    zone.name = name
    zone.profile = profile
    lighting_zone_container.add_child(zone)
    zone.global_position = gridmap.to_global(gridmap.map_to_local(center))
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    var half := get_half_size()
    box.size = Vector3((half.x + 1) * gridmap.cell_size.x, 4.0, (half.y + 1) * gridmap.cell_size.z)
    shape.shape = box
    zone.add_child(shape)

func build_required_input_sequence() -> void:
    required_inputs.clear()
    var count := definition.switch_count if definition.puzzle_type != ProceduralPuzzleRoomDefinition.PuzzleRoomType.PRESSURE_PLATES else definition.pressure_plate_count
    for i in range(count): required_inputs.append(i)
    if definition.puzzle_type == ProceduralPuzzleRoomDefinition.PuzzleRoomType.SWITCH_SEQUENCE:
        required_inputs.shuffle()

func register_input(index: int) -> void:
    if solved: return
    activated_inputs.append(index)
    if check_solution(): solve_room()

func check_solution() -> bool:
    if activated_inputs.size() < required_inputs.size(): return false
    for i in range(required_inputs.size()):
        if activated_inputs[i] != required_inputs[i]:
            activated_inputs.clear()
            return false
    return true

func solve_room() -> void:
    solved = true
    puzzle_room_solved.emit(definition.id)

func create_socket(name: String, tags: Array[String], pos: Vector3) -> void:
    if socket_container == null: return
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

func random_inside_world(center: Vector3i) -> Vector3:
    return gridmap.to_global(gridmap.map_to_local(random_inside_cell(center)))

func set_tile(cell: Vector3i, tile_id: String) -> void:
    var item := resolve_item(tile_id)
    if item >= 0: gridmap.set_cell_item(cell, item)

func resolve_item(tile_id: String) -> int:
    if tile_item_lookup.has(tile_id): return int(tile_item_lookup[tile_id])
    return gridmap.mesh_library.find_item_by_name(tile_id)

func pick(ids: Array[String]) -> String:
    if ids.is_empty(): return ""
    return ids[rng.randi_range(0, ids.size() - 1)]
