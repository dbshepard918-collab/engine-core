class_name GridMapDistrictPainter
extends Node3D

@export var gridmap: GridMap
@export var mesh_library: MeshLibrary
@export var tile_library: TileLibraryDefinition
@export var district_tag: String = "lower_grid"
@export var width: int = 24
@export var height: int = 24
@export var seed_value: int = 0
@export var floor_item_name_prefix: String = "floor_"
@export var wall_item_name_prefix: String = "wall_"

var rng := RandomNumberGenerator.new()

func generate_from_mask(mask: Array[String]) -> void:
    rng.seed = seed_value if seed_value != 0 else randi()
    gridmap.clear()
    for y in range(mask.size()):
        var row := mask[y]
        for x in range(row.length()):
            var c := row[x]
            match c:
                ".": paint_role(Vector3i(x, 0, y), TileDefinition.TileRole.FLOOR)
                "#": paint_role(Vector3i(x, 0, y), TileDefinition.TileRole.WALL)
                "D": paint_role(Vector3i(x, 0, y), TileDefinition.TileRole.DOORWAY)
                "H": paint_role(Vector3i(x, 0, y), TileDefinition.TileRole.HAZARD)
                "L": paint_role(Vector3i(x, 0, y), TileDefinition.TileRole.LANDMARK)
                _: pass

func paint_role(cell: Vector3i, role: int) -> void:
    var candidates := tile_library.by_role(role, district_tag)
    if candidates.is_empty(): return
    var t := weighted_pick(candidates)
    var item_id := mesh_library.find_item_by_name(t.id)
    if item_id < 0:
        push_warning("MeshLibrary missing item: " + t.id)
        return
    gridmap.set_cell_item(cell, item_id)

func weighted_pick(items: Array[TileDefinition]) -> TileDefinition:
    var total := 0.0
    for i in items: total += maxf(0.01, i.weight)
    var roll := rng.randf_range(0.0, total)
    var run := 0.0
    for i in items:
        run += maxf(0.01, i.weight)
        if roll <= run: return i
    return items[0]
