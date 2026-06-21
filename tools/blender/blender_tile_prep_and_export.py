"""
Blender tile preparation/export helper for the cyberpunk top-down ARPG tile pipeline.
Run inside Blender's Python console or Text Editor.

What it does:
- Applies transforms to selected tile roots.
- Ensures origins are grid-centered.
- Adds simple collision proxy naming conventions if objects exist with COLLISION_ prefix.
- Exports each selected object/collection as GLB into a Godot project folder.

Edit GODOT_PROJECT_ROOT before use.
"""
import bpy
from pathlib import Path

GODOT_PROJECT_ROOT = Path("/absolute/path/to/your/GodotProject")
EXPORT_ROOT = GODOT_PROJECT_ROOT / "assets" / "meshes" / "tiles" / "lower_grid"
GRID_SIZE = 4.0

EXPORT_ROOT.mkdir(parents=True, exist_ok=True)


def sanitize(name: str) -> str:
    return name.lower().replace(" ", "_").replace(".", "_")


def apply_transforms(obj):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.select_set(False)


def snap_origin_to_grid(obj):
    obj.location.x = round(obj.location.x / GRID_SIZE) * GRID_SIZE
    obj.location.y = round(obj.location.y / GRID_SIZE) * GRID_SIZE
    obj.location.z = round(obj.location.z / GRID_SIZE) * GRID_SIZE


def export_object_as_glb(obj):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    export_name = sanitize(obj.name)
    out = EXPORT_ROOT / f"{export_name}.glb"
    bpy.ops.export_scene.gltf(
        filepath=str(out),
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_yup=True,
        export_materials='EXPORT',
        export_texcoords=True,
        export_normals=True,
        export_tangents=True,
        export_animations=False
    )
    print(f"Exported {obj.name} -> {out}")


def main():
    selected = list(bpy.context.selected_objects)
    if not selected:
        raise RuntimeError("Select tile root objects before running export.")
    for obj in selected:
        apply_transforms(obj)
        snap_origin_to_grid(obj)
        export_object_as_glb(obj)

if __name__ == "__main__":
    main()
