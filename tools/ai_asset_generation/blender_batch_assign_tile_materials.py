"""
Assigns simple material slots for tile meshes before export.
Use consistent material names so Godot import review is predictable.
"""
import bpy

MATERIALS = {
    "MAT_floor_wet_asphalt": (0.03, 0.03, 0.04, 1.0),
    "MAT_wall_dark_metal": (0.02, 0.025, 0.03, 1.0),
    "MAT_neon_cyan_emissive": (0.0, 0.8, 1.0, 1.0),
    "MAT_neon_magenta_emissive": (1.0, 0.0, 0.8, 1.0),
    "MAT_collision_proxy": (1.0, 0.2, 0.0, 0.35),
}

for name, color in MATERIALS.items():
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        if "neon" in name:
            bsdf.inputs["Emission Color"].default_value = color
            bsdf.inputs["Emission Strength"].default_value = 2.0

for obj in bpy.context.selected_objects:
    if obj.type != 'MESH': continue
    if not obj.data.materials:
        obj.data.materials.append(bpy.data.materials["MAT_floor_wet_asphalt"])
    if obj.name.startswith("COLLISION_"):
        obj.data.materials.clear()
        obj.data.materials.append(bpy.data.materials["MAT_collision_proxy"])
        obj.display_type = 'WIRE'
        obj.hide_render = True
print("Assigned tile material templates.")
