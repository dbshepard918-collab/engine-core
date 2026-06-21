@tool
class_name TilePlacementValidator
extends Node

@export var gridmap: GridMap
@export var rules: Array[TilePlacementRule] = []
@export var max_dynamic_lights_per_16_cells: int = 8
@export var require_dungeon_entrance_socket: bool = true

func validate() -> Array[String]:
    var errors: Array[String] = []
    if gridmap == null:
        return ["TilePlacementValidator: GridMap is not assigned."]
    if gridmap.mesh_library == null:
        return ["TilePlacementValidator: GridMap has no MeshLibrary."]
    var used := gridmap.get_used_cells()
    var name_by_cell := {}
    for cell in used:
        var item := gridmap.get_cell_item(cell)
        if item == GridMap.INVALID_CELL_ITEM: continue
        name_by_cell[cell] = gridmap.mesh_library.get_item_name(item)
    validate_neighbor_rules(name_by_cell, errors)
    validate_dungeon_entrance_rules(name_by_cell, errors)
    validate_dynamic_light_budget(errors)
    return errors

func validate_neighbor_rules(name_by_cell: Dictionary, errors: Array[String]) -> void:
    for rule in rules:
        if rule.rule_type != TilePlacementRule.RuleType.REQUIRED_NEIGHBOR and rule.rule_type != TilePlacementRule.RuleType.FORBIDDEN_NEIGHBOR:
            continue
        for cell in name_by_cell.keys():
            if name_by_cell[cell] != rule.tile_id: continue
            var ncell: Vector3i = cell + rule.neighbor_direction
            var neighbor_name := str(name_by_cell.get(ncell, ""))
            var has_match := rule.neighbor_tile_ids.has(neighbor_name)
            if rule.rule_type == TilePlacementRule.RuleType.REQUIRED_NEIGHBOR and not has_match:
                errors.append("%s at %s requires neighbor %s in direction %s" % [rule.tile_id, str(cell), str(rule.neighbor_tile_ids), str(rule.neighbor_direction)])
            if rule.rule_type == TilePlacementRule.RuleType.FORBIDDEN_NEIGHBOR and has_match:
                errors.append("%s at %s has forbidden neighbor %s at %s" % [rule.tile_id, str(cell), neighbor_name, str(ncell)])

func validate_dungeon_entrance_rules(name_by_cell: Dictionary, errors: Array[String]) -> void:
    for cell in name_by_cell.keys():
        var tile_name := str(name_by_cell[cell])
        if tile_name.contains("dungeon") or tile_name.contains("entrance") or tile_name.contains("boss_gate"):
            var world_pos := gridmap.to_global(gridmap.map_to_local(cell))
            if not has_nearby_socket(world_pos, "dungeon_main") and not has_nearby_socket(world_pos, "dungeon_side") and require_dungeon_entrance_socket:
                errors.append("Dungeon entrance tile %s at %s has no nearby dungeon socket." % [tile_name, str(cell)])

func has_nearby_socket(world_pos: Vector3, tag: String, max_dist: float = 6.0) -> bool:
    for socket in get_tree().get_nodes_in_group("placement_sockets"):
        if socket is PlacementSocket and socket.has_tag(tag) and socket.global_position.distance_to(world_pos) <= max_dist:
            return true
    return false

func validate_dynamic_light_budget(errors: Array[String]) -> void:
    var lights := get_tree().get_nodes_in_group("tile_dynamic_lights")
    if lights.size() > max_dynamic_lights_per_16_cells:
        errors.append("Dynamic light budget warning: %d tile lights found; budget is %d for this validation scope." % [lights.size(), max_dynamic_lights_per_16_cells])

func print_report() -> void:
    var result := validate()
    if result.is_empty():
        print("Tile placement validation passed.")
    else:
        push_warning("Tile placement validation found %d issue(s)." % result.size())
        for e in result: push_warning(e)
