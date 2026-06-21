@tool
class_name TileSetValidator
extends Node

@export var mesh_library: MeshLibrary
@export var required_tile_ids: Array[String] = [
    "floor_plain_4m", "floor_wet_asphalt_4m", "floor_metal_grate_4m",
    "wall_solid_neon_4m", "wall_doorway_4m", "wall_corner_inner_4m",
    "stairs_down_4m", "bridge_catwalk_4m", "landmark_clinic_kiosk_8m"
]

func validate() -> Array[String]:
    var errors: Array[String] = []
    if mesh_library == null:
        return ["MeshLibrary is not assigned."]
    var names := []
    for id in mesh_library.get_item_list():
        names.append(mesh_library.get_item_name(id))
    for req in required_tile_ids:
        if not names.has(req): errors.append("Missing tile: " + req)
    return errors
