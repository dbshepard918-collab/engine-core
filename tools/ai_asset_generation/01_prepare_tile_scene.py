# Run inside Blender after opening your lower_grid tile source .blend.
# Purpose: Normalize transforms, enforce naming checks, and create export collections.

import bpy
from mathutils import Vector

TILE_PREFIXES = (
    "floor_", "corridor_", "wall_", "stairs_", "stair_",
    "dungeon_", "boss_", "hazard_", "cover_"
)
EXPORT_COLLECTION_NAME = "EXPORT_LOWER_GRID_TILES"
GRID_SIZE_METERS = 4.0


def ensure_collection(name: str):
    coll = bpy.data.collections.get(name)
    if not coll:
        coll = bpy.data.collections.new(name)
        bpy.context.scene.collection.children.link(coll)
    return coll


def is_tile_object(obj):
    return obj.type == "MESH" and obj.name.startswith(TILE_PREFIXES)


def apply_object_cleanup(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    obj["tile_id"] = obj.name
    obj["grid_size_meters"] = GRID_SIZE_METERS
    obj["godot_target_folder"] = "res://scenes/tiles/lower_grid/"


def main():
    export_coll = ensure_collection(EXPORT_COLLECTION_NAME)
    tile_count = 0
    warnings = []
    for obj in bpy.context.scene.objects:
        if is_tile_object(obj):
            apply_object_cleanup(obj)
            tile_count += 1
            if obj.name not in export_coll.objects:
                try:
                    export_coll.objects.link(obj)
                except RuntimeError:
                    pass
            dims = obj.dimensions
            if dims.x > 0 and abs((dims.x / GRID_SIZE_METERS) - round(dims.x / GRID_SIZE_METERS)) > 0.05:
                warnings.append(f"{obj.name}: X dimension {dims.x:.2f} is not near a 4m multiple")
            if dims.y > 0 and abs((dims.y / GRID_SIZE_METERS) - round(dims.y / GRID_SIZE_METERS)) > 0.05:
                warnings.append(f"{obj.name}: Y dimension {dims.y:.2f} is not near a 4m multiple")
    print(f"Prepared {tile_count} tile mesh objects.")
    for warning in warnings:
        print("WARNING:", warning)

if __name__ == "__main__":
    main()
