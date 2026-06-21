@tool
class_name CorridorTilePlacementValidator
extends Node

@export var gridmap: GridMap
@export var rules: CorridorTilePlacementRules
@export var y_level: int = 0

func validate() -> Array[String]:
    var errors: Array[String] = []
    if gridmap == null or gridmap.mesh_library == null:
        return ["CorridorTilePlacementValidator requires GridMap with MeshLibrary."]
    if rules == null:
        return ["CorridorTilePlacementValidator requires CorridorTilePlacementRules."]
    var cells := build_cell_name_map()
    var dead_ends := 0
    for cell in cells.keys():
        var id := str(cells[cell])
        if is_corridor(id):
            var walkable_neighbors := count_walkable_neighbors(cell, cells)
            if walkable_neighbors <= 0:
                errors.append("Corridor tile %s at %s is isolated." % [id, str(cell)])
            if walkable_neighbors == 1:
                dead_ends += 1
                if not rules.allow_single_tile_branches and not is_near_entrance_or_loot(cell, cells):
                    errors.append("Corridor dead end at %s is not near entrance/loot room." % str(cell))
            if rules.require_wall_border:
                validate_wall_border(cell, cells, errors)
            if rules.require_doorway_at_room_transition:
                validate_transitions(cell, cells, errors)
    if dead_ends > rules.max_dead_ends:
        errors.append("Too many corridor dead ends: %d; max allowed %d." % [dead_ends, rules.max_dead_ends])
    return errors

func build_cell_name_map() -> Dictionary:
    var out := {}
    for cell in gridmap.get_used_cells():
        if cell.y != y_level: continue
        var item := gridmap.get_cell_item(cell)
        if item == GridMap.INVALID_CELL_ITEM: continue
        out[cell] = gridmap.mesh_library.get_item_name(item)
    return out

func count_walkable_neighbors(cell: Vector3i, cells: Dictionary) -> int:
    var count := 0
    for d in cardinal():
        var id := str(cells.get(cell + d, ""))
        if is_corridor(id) or rules.doorway_ids.has(id) or rules.entrance_ids.has(id): count += 1
    return count

func validate_wall_border(cell: Vector3i, cells: Dictionary, errors: Array[String]) -> void:
    var bordering_walls := 0
    for d in cardinal():
        if rules.wall_ids.has(str(cells.get(cell + d, ""))): bordering_walls += 1
    if bordering_walls == 0:
        errors.append("Corridor tile at %s has no adjacent wall/border tile; it may read as open floor." % str(cell))

func validate_transitions(cell: Vector3i, cells: Dictionary, errors: Array[String]) -> void:
    for d in cardinal():
        var neighbor := str(cells.get(cell + d, ""))
        if neighbor.begins_with("room_") and not rules.doorway_ids.has(str(cells.get(cell + d, ""))):
            errors.append("Corridor at %s transitions to room tile without doorway marker." % str(cell))

func is_near_entrance_or_loot(cell: Vector3i, cells: Dictionary) -> bool:
    for d in cardinal():
        var id := str(cells.get(cell + d, ""))
        if rules.entrance_ids.has(id) or id.contains("loot") or id.contains("reward"): return true
    return false

func is_corridor(id: String) -> bool:
    return rules.corridor_floor_ids.has(id) or rules.intersection_ids.has(id)

func cardinal() -> Array[Vector3i]:
    return [Vector3i(1,0,0), Vector3i(-1,0,0), Vector3i(0,0,1), Vector3i(0,0,-1)]

func print_report() -> void:
    var result := validate()
    if result.is_empty(): print("Corridor placement validation passed.")
    else:
        push_warning("Corridor placement validation found %d issue(s)." % result.size())
        for e in result: push_warning(e)
