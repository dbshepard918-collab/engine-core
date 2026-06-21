import bpy
from pathlib import Path
EXPORT_DIR = Path("/absolute/path/to/CyberARPG/assets/meshes/generated")
EXPORT_DIR.mkdir(parents=True, exist_ok=True)
for obj in bpy.context.selected_objects:
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True); bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    safe_name = obj.name.lower().replace(" ", "_")
    out = EXPORT_DIR / f"{safe_name}.glb"
    bpy.ops.export_scene.gltf(filepath=str(out), export_format='GLB', use_selection=True, export_apply=True, export_animations=True)
    print(f"Exported {obj.name} -> {out}")
