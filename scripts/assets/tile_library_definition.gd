class_name TileLibraryDefinition
extends Resource

@export var id: String
@export var grid_size: float = 4.0
@export var tiles: Array[TileDefinition] = []

func by_role(role: int, district_tag: String = "") -> Array[TileDefinition]:
    var out: Array[TileDefinition] = []
    for t in tiles:
        if t.role != role: continue
        if district_tag != "" and not t.district_tags.has(district_tag): continue
        out.append(t)
    return out

func get_tile(id: String) -> TileDefinition:
    for t in tiles:
        if t.id == id: return t
    return null
