class_name WorldMapRevealState
extends Resource

@export var discovered_cells: Dictionary = {} # region_id -> Array[String]
@export var discovered_pois: Dictionary = {} # poi_id -> true
@export var unlocked_fast_travel: Dictionary = {} # poi_id -> true

func discover_cell(region_id: String, cell: Vector2i) -> void:
    if not discovered_cells.has(region_id): discovered_cells[region_id] = []
    var key := "%d,%d" % [cell.x, cell.y]
    if not discovered_cells[region_id].has(key): discovered_cells[region_id].append(key)

func discover_poi(poi_id: String) -> void:
    discovered_pois[poi_id] = true

func unlock_fast_travel(poi_id: String) -> void:
    unlocked_fast_travel[poi_id] = true
    discover_poi(poi_id)
