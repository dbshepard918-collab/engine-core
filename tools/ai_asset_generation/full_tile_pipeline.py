# full_tile_pipeline.py - Comprehensive tile pipeline combining all V8 steps
import bpy, os
from pathlib import Path
from mathutils import Vector

print("=" * 60)
print("FULL TILE PIPELINE - V8 Cyberpunk Dream Textures")
print("=" * 60)

GRID_SIZE_METERS = 4.0
TILE_PREFIXES = ("floor_", "wall_", "corridor_", "stair_", "door_", "prop_", "ceiling_")
EXPORT_COLLECTION_NAME = "EXPORT_LOWER_GRID_TILES"
IMAGE_SIZE = 1024
PASSES = ["DIFFUSE", "ROUGHNESS", "EMIT", "NORMAL"]

PROJECT_ROOT = Path(os.getcwd())
TILE_GLB_DIR = PROJECT_ROOT / "assets" / "meshes" / "tiles" / "lower_grid"
EXPORT_DIR = PROJECT_ROOT / "assets" / "meshes" / "tiles" / "lower_grid"
BAKE_FOLDER = PROJECT_ROOT / "assets" / "textures" / "tiles" / "baked"
BAKE_FOLDER.mkdir(parents=True, exist_ok=True)
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

print(f"Project root: {PROJECT_ROOT}")
print(f"Tile GLB dir: {TILE_GLB_DIR}")

# STEP 1: IMPORT GLB TILES
print("\n--- STEP 1: Importing GLB tiles into scene ---")
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

imported_count = 0
if TILE_GLB_DIR.exists():
    for glb_file in TILE_GLB_DIR.glob("*.glb"):
        bpy.ops.import_scene.gltf(filepath=str(glb_file))
        imported_count += 1
        print(f"  Imported: {glb_file.name}")
print(f"Imported {imported_count} GLB tile files.")

# STEP 2: PREPARE TILE SCENE (01_prepare_tile_scene.py logic)
print("\n--- STEP 2: Preparing tiles (grid alignment) ---")

def is_tile_object(obj):
    return obj.type == "MESH" and obj.name.startswith(TILE_PREFIXES)

if EXPORT_COLLECTION_NAME not in bpy.data.collections:
    export_col = bpy.data.collections.new(EXPORT_COLLECTION_NAME)
    bpy.context.scene.collection.children.link(export_col)
else:
    export_col = bpy.data.collections[EXPORT_COLLECTION_NAME]

tile_count = 0
for obj in list(bpy.context.scene.objects):
    if is_tile_object(obj):
        tile_count += 1
        obj["tile_id"] = obj.name
        obj["grid_size_meters"] = GRID_SIZE_METERS
        obj["godot_target_folder"] = "res://scenes/tiles/lower_grid/"
        obj.location.x = round(obj.location.x / GRID_SIZE_METERS) * GRID_SIZE_METERS
        obj.location.y = round(obj.location.y / GRID_SIZE_METERS) * GRID_SIZE_METERS
        obj.location.z = round(obj.location.z * 4) / 4
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
        if obj.name not in export_col.objects:
            export_col.objects.link(obj)
        print(f"  Prepared: {obj.name}")
print(f"Prepared {tile_count} tile mesh objects.")

# STEP 3: BATCH ASSIGN PBR MATERIALS
print("\n--- STEP 3: Batch assigning PBR materials ---")
MATERIAL_CONFIGS = {
    "floor_": {"base_color": (0.15, 0.15, 0.18, 1.0), "roughness": 0.7, "metallic": 0.3, "emission": (0.0, 0.8, 0.8, 1.0), "emission_strength": 0.2},
    "wall_": {"base_color": (0.1, 0.1, 0.12, 1.0), "roughness": 0.6, "metallic": 0.4, "emission": (0.0, 0.9, 1.0, 1.0), "emission_strength": 0.5},
    "corridor_": {"base_color": (0.12, 0.12, 0.15, 1.0), "roughness": 0.65, "metallic": 0.35, "emission": (0.8, 0.0, 0.8, 1.0), "emission_strength": 0.3},
    "stair_": {"base_color": (0.2, 0.2, 0.22, 1.0), "roughness": 0.8, "metallic": 0.2, "emission": (0.0, 0.6, 0.6, 1.0), "emission_strength": 0.15},
}

def create_pbr_material(obj, config):
    mat_name = f"{obj.name}_PBR"
    mat = bpy.data.materials.new(name=mat_name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.location = (0, 0)
    bsdf.inputs["Base Color"].default_value = config["base_color"]
    bsdf.inputs["Roughness"].default_value = config["roughness"]
    bsdf.inputs["Metallic"].default_value = config["metallic"]
    bsdf.inputs["Emission Color"].default_value = config["emission"]
    bsdf.inputs["Emission Strength"].default_value = config["emission_strength"]
    output = nodes.new("ShaderNodeOutputMaterial")
    output.location = (300, 0)
    links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)
    return mat

materials_assigned = 0
for obj in bpy.context.scene.objects:
    if is_tile_object(obj):
        for prefix, config in MATERIAL_CONFIGS.items():
            if obj.name.startswith(prefix):
                create_pbr_material(obj, config)
                materials_assigned += 1
                print(f"  Assigned PBR material to: {obj.name}")
                break
print(f"Assigned {materials_assigned} PBR materials.")

# STEP 4: BAKE TEXTURES (02_bake_tile_texture_sets.py logic)
print("\n--- STEP 4: Baking texture sets ---")
bpy.context.scene.render.engine = 'CYCLES'
bpy.context.scene.cycles.device = 'CPU'
bpy.context.scene.cycles.samples = 4

baked_count = 0
for obj in list(bpy.context.scene.objects):
    if not is_tile_object(obj):
        continue
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    for pass_name in PASSES:
        image_name = f"{obj.name}_{pass_name.lower()}"
        img = bpy.data.images.get(image_name)
        if not img:
            img = bpy.data.images.new(image_name, IMAGE_SIZE, IMAGE_SIZE)
        img.filepath_raw = str(BAKE_FOLDER / f"{image_name}.png")
        img.file_format = 'PNG'
        if obj.active_material and obj.active_material.use_nodes:
            nodes = obj.active_material.node_tree.nodes
            for n in list(nodes):
                if n.name == "BAKE_TARGET":
                    nodes.remove(n)
            bake_node = nodes.new("ShaderNodeTexImage")
            bake_node.name = "BAKE_TARGET"
            bake_node.image = img
            nodes.active = bake_node
            try:
                bpy.ops.object.bake(type=pass_name)
                img.save()
                baked_count += 1
                print(f"  Baked {pass_name} for {obj.name}")
            except Exception as exc:
                print(f"  WARNING: Bake failed {obj.name}/{pass_name}: {exc}")
print(f"Baked {baked_count} texture passes total.")

# STEP 5: EXPORT GLB (03_export_lower_grid_glb.py logic)
print("\n--- STEP 5: Exporting tiles as GLB ---")
exported = 0
for obj in list(bpy.context.scene.objects):
    if not is_tile_object(obj):
        continue
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    out_path = str(EXPORT_DIR / f"{obj.name}.glb")
    bpy.ops.export_scene.gltf(
        filepath=out_path,
        use_selection=True,
        export_format='GLB',
        export_apply=True,
        export_materials='EXPORT',
        export_texcoords=True,
        export_normals=True,
        export_tangents=True,
        export_yup=True,
    )
    exported += 1
    print(f"  Exported: {obj.name} -> {out_path}")
print(f"Exported {exported} GLB files to {EXPORT_DIR}")

# SUMMARY
print("\n" + "=" * 60)
print("PIPELINE COMPLETE")
print(f"  Tiles imported: {imported_count}")
print(f"  Tiles prepared/aligned: {tile_count}")
print(f"  PBR materials assigned: {materials_assigned}")
print(f"  Texture passes baked: {baked_count}")
print(f"  GLB files exported: {exported}")
print(f"  Grid size: {GRID_SIZE_METERS}m")
print(f"  Bake resolution: {IMAGE_SIZE}x{IMAGE_SIZE}")
print("=" * 60)
