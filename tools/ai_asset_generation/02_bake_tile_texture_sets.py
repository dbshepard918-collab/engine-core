# Run inside Blender when tile assets are ready for texture baking.
# Purpose: Create image placeholders and bake configured render passes for selected objects.
# This script is conservative: it creates bake targets and runs Blender's bake operator.
# Confirm Cycles device/settings manually before high-volume baking.

import bpy
from pathlib import Path

BAKE_FOLDER = Path(bpy.path.abspath("//baked_textures"))
BAKE_FOLDER.mkdir(parents=True, exist_ok=True)
IMAGE_SIZE = 2048
PASSES = ["DIFFUSE", "ROUGHNESS", "EMIT", "NORMAL"]


def ensure_bake_image(obj, pass_name):
    image_name = f"{obj.name}_{pass_name.lower()}"
    img = bpy.data.images.get(image_name)
    if not img:
        img = bpy.data.images.new(image_name, IMAGE_SIZE, IMAGE_SIZE)
        img.filepath_raw = str(BAKE_FOLDER / f"{image_name}.png")
        img.file_format = 'PNG'
    return img


def assign_image_node(obj, image):
    if not obj.active_material:
        mat = bpy.data.materials.new(obj.name + "_mat")
        mat.use_nodes = True
        obj.active_material = mat
    mat = obj.active_material
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    node = nodes.new("ShaderNodeTexImage")
    node.name = "BAKE_TARGET"
    node.image = image
    nodes.active = node


def bake_selected():
    bpy.context.scene.render.engine = 'CYCLES'
    selected = [o for o in bpy.context.selected_objects if o.type == 'MESH']
    if not selected:
        print("No mesh objects selected for baking.")
        return
    for obj in selected:
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        for pass_name in PASSES:
            img = ensure_bake_image(obj, pass_name)
            assign_image_node(obj, img)
            try:
                bpy.ops.object.bake(type=pass_name)
                img.save()
                print(f"Baked {pass_name} for {obj.name}: {img.filepath_raw}")
            except Exception as exc:
                print(f"WARNING: Bake failed for {obj.name} pass {pass_name}: {exc}")

if __name__ == "__main__":
    bake_selected()
