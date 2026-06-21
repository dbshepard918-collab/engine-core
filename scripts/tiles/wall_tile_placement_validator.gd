@tool
class_name WallTilePlacementValidator
extends Node

@export var gridmap: GridMap
@export var rules: WallTilePlacementRules
@export var y_level: int = 0

func validate() -> Array[String]:
    var errors: Array[String] = []
    if gridmap == null or gridmap.mesh_library == null:
        return ["WallTilePlacementValidator requires GridMap with MeshLibrary."]
    if rules == null:
        return ["WallTilePlacementValidator requires WallTilePlacementRules."]
    var cells := build_cell_name_map()
    for cell in cells.keys():
        var name := str(cells[cell])
        if is_wall(name): validate_wall_cell(cell, name, cells, errors)
        if rules.validate_doorways and rules.doorway_ids.has(name): validate_doorway(cell, cells, errors)
        if rules.validate_corners and (rules.corner_inner_ids.has(name) or rules.corner_outer_ids.has(name)): validate_corner(cell, name, cells, errors)
    return errors

func build_cell_name_map() -> Dictionary:
    var out := {}
    for cell in gridmap.get_used_cells():
        if cell.y != y_level: continue
        var item := gridmap.get_cell_item(cell)
        if item == GridMap.INVALID_CELL_ITEM: continue
        out[cell] = gridmap.mesh_library.get_item_name(item)
    return out

func validate_wall_cell(cell: Vector3i, name: String, cells: Dictionary, errors: Array[String]) -> void:
    if rules.require_floor_inside_wall:
        var has_floor_neighbor := false
        for d in cardinal():
            if rules.floor_ids.has(str(cells.get(cell + d, ""))): has_floor_neighbor = true
        if not has_floor_neighbor:
            errors.append("Wall %s at %s has no adjacent floor/corridor tile." % [name, str(cell)])
    if not rules.allow_double_thick_walls:
        var wall_neighbors := 0
        for d in cardinal():
            if is_wall(str(cells.get(cell + d, ""))): wall_neighbors += 1
        if wall_neighbors >= 4:
            errors.append("Wall %s at %s appears buried in a solid block; check double-thick wall placement." % [name, str(cell)])
    for d in cardinal():
        var neighbor := str(cells.get(cell + d, ""))
        if rules.forbidden_wall_touch_ids.has(neighbor):
            errors.append("Wall %s at %s touches forbidden tile %s at %s." % [name, str(cell), neighbor, str(cell + d)])

func validate_doorway(cell: Vector3i, cells: Dictionary, errors: Array[String]) -> void:
    var north_south := rules.floor_ids.has(str(cells.get(cell + Vector3i.FORWARD, ""))) and rules.floor_ids.has(str(cells.get(cell + Vector3i.BACK, "")))
    var east_west := rules.floor_ids.has(str(cells.get(cell + Vector3i.RIGHT, ""))) and rules.floor_ids.has(str(cells.get(cell + Vector3i.LEFT, "")))
    if not north_south and not east_west:
        errors.append("Doorway at %s does not connect two walkable floor/corridor cells." % str(cell))

func validate_corner(cell: Vector3i, name: String, cells: Dictionary, errors: Array[String]) -> void:
    var floor_count := 0
    var wall_count := 0
    for d in cardinal():
        var n := str(cells.get(cell + d, ""))
        if rules.floor_ids.has(n): floor_count += 1
        if is_wall(n): wall_count += 1
    if floor_count == 0 or wall_count == 0:
        errors.append("Corner %s at %s lacks expected mix of wall and floor neighbors." % [name, str(cell)])

func is_wall(id: String) -> bool:
    return rules.solid_wall_ids.has(id) or rules.doorway_ids.has(id) or rules.corner_inner_ids.has(id) or rules.corner_outer_ids.has(id)

func cardinal() -> Array[Vector3i]:
    return [Vector3i(1,0,0), Vector3i(-1,0,0), Vector3i(0,0,1), Vector3i(0,0,-1)]

func print_report() -> void:
    var result := validate()
    if result.is_empty(): print("Wall placement validation passed.")
    else:
        push_warning("Wall placement validation found %d issue(s)." % result.size())
        for e in result: push_warning(e)
