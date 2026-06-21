@tool
class_name StaircaseTilePlacementValidator
extends Node

@export var gridmap: GridMap
@export var rules: StaircaseTilePlacementRules

func validate() -> Array[String]:
    var errors: Array[String] = []
    if gridmap == null or gridmap.mesh_library == null:
        return ["StaircaseTilePlacementValidator requires GridMap with MeshLibrary."]
    if rules == null:
        return ["StaircaseTilePlacementValidator requires StaircaseTilePlacementRules."]
    var cells := build_cell_name_map()
    var stair_count := 0
    for cell in cells.keys():
        var id := str(cells[cell])
        if is_stair(id):
            stair_count += 1
            validate_stair(cell, id, cells, errors)
    if stair_count > rules.max_stairs_per_room:
        errors.append("Too many stair tiles in validation scope: %d; max %d." % [stair_count, rules.max_stairs_per_room])
    return errors

func build_cell_name_map() -> Dictionary:
    var out := {}
    for cell in gridmap.get_used_cells():
        var item := gridmap.get_cell_item(cell)
        if item == GridMap.INVALID_CELL_ITEM: continue
        out[cell] = gridmap.mesh_library.get_item_name(item)
    return out

func validate_stair(cell: Vector3i, id: String, cells: Dictionary, errors: Array[String]) -> void:
    if rules.require_landing_top_bottom:
        var has_landing := false
        for d in cardinal():
            var near_id := str(cells.get(cell + d, ""))
            if rules.landing_ids.has(near_id) or rules.corridor_ids.has(near_id): has_landing = true
        if not has_landing:
            errors.append("Stair %s at %s has no adjacent landing/corridor." % [id, str(cell)])
    if rules.require_clear_forward_cell:
        for d in cardinal():
            var blocked := str(cells.get(cell + d, ""))
            if rules.blocked_ids.has(blocked):
                errors.append("Stair %s at %s is adjacent to blocking tile %s at %s; check clearance." % [id, str(cell), blocked, str(cell + d)])
    if rules.require_direction_pair:
        var expected_y := cell.y + (rules.allowed_y_delta if rules.stair_up_ids.has(id) else -rules.allowed_y_delta)
        var has_pair := false
        for d in cardinal():
            var other_cell := Vector3i(cell.x + d.x, expected_y, cell.z + d.z)
            var other_id := str(cells.get(other_cell, ""))
            if rules.landing_ids.has(other_id) or rules.corridor_ids.has(other_id): has_pair = true
        if not has_pair:
            errors.append("Stair %s at %s has no valid paired landing on expected Y level %d." % [id, str(cell), expected_y])

func is_stair(id: String) -> bool:
    return rules.stair_up_ids.has(id) or rules.stair_down_ids.has(id)

func cardinal() -> Array[Vector3i]:
    return [Vector3i(1,0,0), Vector3i(-1,0,0), Vector3i(0,0,1), Vector3i(0,0,-1)]

func print_report() -> void:
    var result := validate()
    if result.is_empty(): print("Staircase placement validation passed.")
    else:
        push_warning("Staircase placement validation found %d issue(s)." % result.size())
        for e in result: push_warning(e)
