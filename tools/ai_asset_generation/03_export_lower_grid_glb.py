# Run inside Blender after prepare/bake.
# Purpose: Export each tile object as an individual GLB into the Godot project.
# Edit GODOT_PROJECT_ROOT before running.

import bpy
from pathlib import Path

GODOT_PROJECT_ROOT = Path("C:/Users/dbshe/OneDrive/Documents/engine-core")
EXPORT_DIR = GODOT_PROJECT_ROOT / "assets" / "meshes" / "tiles" / "lower_grid"
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

TILE_PREFIXES = (
    "floor_", "corridor_", "wall_", "stairs_", "stair_",
    "dungeon_", "boss_", "hazard_", "cover_"
)


def is_tile_object(obj):
    return obj.type == "MESH" and obj.name.startswith(TILE_PREFIXES)


def export_tile(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    out_path = EXPORT_DIR / f"{obj.name}.glb"
    bpy.ops.export_scene.gltf(
        filepath=str(out_path),
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_materials='EXPORT',
        export_texcoords=True,
        export_normals=True,
        export_tangents=True,
        export_yup=True,
    )
    print(f"Exported {obj.name} -> {out_path}")


def main():
    exported = 0
    for obj in bpy.context.scene.objects:
        if is_tile_object(obj):
            export_tile(obj)
            exported += 1
    print(f"Exported {exported} GLB tile files to {EXPORT_DIR}")

if __name__ == "__main__":
    main()
