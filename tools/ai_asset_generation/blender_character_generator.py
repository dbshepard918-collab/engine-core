"""
blender_character_generator.py
Generates cyberpunk character models in Blender, bakes PBR textures, and exports as GLB.
Run with: blender --background --python blender_character_generator.py
"""
import bpy
import bmesh
import os
import sys
import math
import random
from mathutils import Vector, Matrix

# Configuration
PROJECT_ROOT = r"C:\Users\dbshe\OneDrive\Documents\engine-core"
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "meshes", "characters")
TEXTURE_DIR = os.path.join(PROJECT_ROOT, "assets", "textures", "characters")
BAKE_RESOLUTION = 1024

# Character definitions - cyberpunk themed
CHARACTERS = [
    {
        "id": "char_mara_voss_001",
        "name": "Mara Voss",
        "description": "Cyberpunk street samurai - athletic female build",
        "body_scale": (0.85, 0.85, 1.0),
        "color_primary": (0.1, 0.05, 0.15, 1.0),
        "color_accent": (0.0, 0.8, 1.0, 1.0),
        "color_skin": (0.6, 0.45, 0.35, 1.0),
        "emission_color": (0.0, 0.8, 1.0, 1.0),
        "region": "lower_grid"
    },
    {
        "id": "char_kael_drex_002",
        "name": "Kael Drex",
        "description": "Cyberpunk hacker - lean male build",
        "body_scale": (0.95, 0.9, 1.05),
        "color_primary": (0.05, 0.05, 0.1, 1.0),
        "color_accent": (1.0, 0.2, 0.0, 1.0),
        "color_skin": (0.45, 0.35, 0.28, 1.0),
        "emission_color": (1.0, 0.3, 0.0, 1.0),
        "region": "upper_grid"
    },
    {
        "id": "char_zara_night_003",
        "name": "Zara Night",
        "description": "Cyberpunk netrunner - slender female build",
        "body_scale": (0.8, 0.8, 0.95),
        "color_primary": (0.02, 0.02, 0.05, 1.0),
        "color_accent": (0.8, 0.0, 1.0, 1.0),
        "color_skin": (0.55, 0.4, 0.3, 1.0),
        "emission_color": (0.6, 0.0, 1.0, 1.0),
        "region": "mid_grid"
    },
]


def clear_scene():
    """Remove all objects from the scene."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)
    for block in bpy.data.images:
        if block.users == 0:
            bpy.data.images.remove(block)


def create_humanoid_mesh(char_data):
    """Create a stylized humanoid character mesh using primitives and modifiers."""
    name = char_data["id"]
    scale = char_data["body_scale"]
    parts = []

    # --- TORSO ---
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.2))
    torso = bpy.context.active_object
    torso.name = f"{name}_torso"
    torso.scale = (0.4 * scale[0], 0.25 * scale[1], 0.5 * scale[2])
    bpy.ops.object.transform_apply(scale=True)
    mod = torso.modifiers.new("Subsurf", 'SUBSURF')
    mod.levels = 2
    mod.render_levels = 2
    parts.append(torso)

    # --- HEAD ---
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(0, 0, 1.75))
    head = bpy.context.active_object
    head.name = f"{name}_head"
    head.scale = (1.0, 0.9, 1.1)
    bpy.ops.object.transform_apply(scale=True)
    parts.append(head)

    # --- NECK ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.15, location=(0, 0, 1.58))
    neck = bpy.context.active_object
    neck.name = f"{name}_neck"
    parts.append(neck)

    # --- HIPS ---
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.7))
    hips = bpy.context.active_object
    hips.name = f"{name}_hips"
    hips.scale = (0.35 * scale[0], 0.22 * scale[1], 0.25 * scale[2])
    bpy.ops.object.transform_apply(scale=True)
    mod = hips.modifiers.new("Subsurf", 'SUBSURF')
    mod.levels = 1
    mod.render_levels = 2
    parts.append(hips)

    # --- LEFT ARM (upper) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.4, location=(-0.45 * scale[0], 0, 1.3))
    l_upper_arm = bpy.context.active_object
    l_upper_arm.name = f"{name}_l_upper_arm"
    l_upper_arm.rotation_euler = (0, 0, math.radians(10))
    parts.append(l_upper_arm)

    # --- LEFT ARM (lower) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.35, location=(-0.5 * scale[0], 0, 0.95))
    l_lower_arm = bpy.context.active_object
    l_lower_arm.name = f"{name}_l_lower_arm"
    parts.append(l_lower_arm)

    # --- RIGHT ARM (upper) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.4, location=(0.45 * scale[0], 0, 1.3))
    r_upper_arm = bpy.context.active_object
    r_upper_arm.name = f"{name}_r_upper_arm"
    r_upper_arm.rotation_euler = (0, 0, math.radians(-10))
    parts.append(r_upper_arm)

    # --- RIGHT ARM (lower) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.05, depth=0.35, location=(0.5 * scale[0], 0, 0.95))
    r_lower_arm = bpy.context.active_object
    r_lower_arm.name = f"{name}_r_lower_arm"
    parts.append(r_lower_arm)

    # --- LEFT LEG (upper) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.45, location=(-0.15, 0, 0.4))
    l_upper_leg = bpy.context.active_object
    l_upper_leg.name = f"{name}_l_upper_leg"
    parts.append(l_upper_leg)

    # --- LEFT LEG (lower) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.45, location=(-0.15, 0, -0.05))
    l_lower_leg = bpy.context.active_object
    l_lower_leg.name = f"{name}_l_lower_leg"
    parts.append(l_lower_leg)

    # --- RIGHT LEG (upper) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.45, location=(0.15, 0, 0.4))
    r_upper_leg = bpy.context.active_object
    r_upper_leg.name = f"{name}_r_upper_leg"
    parts.append(r_upper_leg)

    # --- RIGHT LEG (lower) ---
    bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.45, location=(0.15, 0, -0.05))
    r_lower_leg = bpy.context.active_object
    r_lower_leg.name = f"{name}_r_lower_leg"
    parts.append(r_lower_leg)

    # --- HANDS ---
    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(-0.5 * scale[0], 0, 0.72))
    l_hand = bpy.context.active_object
    l_hand.name = f"{name}_l_hand"
    l_hand.scale = (0.8, 0.5, 1.2)
    bpy.ops.object.transform_apply(scale=True)
    parts.append(l_hand)

    bpy.ops.mesh.primitive_cube_add(size=0.1, location=(0.5 * scale[0], 0, 0.72))
    r_hand = bpy.context.active_object
    r_hand.name = f"{name}_r_hand"
    r_hand.scale = (0.8, 0.5, 1.2)
    bpy.ops.object.transform_apply(scale=True)
    parts.append(r_hand)

    # --- FEET ---
    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(-0.15, 0.04, -0.3))
    l_foot = bpy.context.active_object
    l_foot.name = f"{name}_l_foot"
    l_foot.scale = (0.8, 1.5, 0.5)
    bpy.ops.object.transform_apply(scale=True)
    parts.append(l_foot)

    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(0.15, 0.04, -0.3))
    r_foot = bpy.context.active_object
    r_foot.name = f"{name}_r_foot"
    r_foot.scale = (0.8, 1.5, 0.5)
    bpy.ops.object.transform_apply(scale=True)
    parts.append(r_foot)

    # --- CYBERPUNK DETAILS: Shoulder pads ---
    bpy.ops.mesh.primitive_cube_add(size=0.15, location=(-0.38 * scale[0], 0, 1.45))
    l_shoulder = bpy.context.active_object
    l_shoulder.name = f"{name}_l_shoulder_pad"
    l_shoulder.scale = (1.2, 0.8, 0.6)
    bpy.ops.object.transform_apply(scale=True)
    mod = l_shoulder.modifiers.new("Bevel", 'BEVEL')
    mod.width = 0.01
    mod.segments = 2
    parts.append(l_shoulder)

    bpy.ops.mesh.primitive_cube_add(size=0.15, location=(0.38 * scale[0], 0, 1.45))
    r_shoulder = bpy.context.active_object
    r_shoulder.name = f"{name}_r_shoulder_pad"
    r_shoulder.scale = (1.2, 0.8, 0.6)
    bpy.ops.object.transform_apply(scale=True)
    mod = r_shoulder.modifiers.new("Bevel", 'BEVEL')
    mod.width = 0.01
    mod.segments = 2
    parts.append(r_shoulder)

    # --- CYBERPUNK DETAILS: Visor/helmet piece ---
    bpy.ops.mesh.primitive_cube_add(size=0.2, location=(0, -0.12, 1.78))
    visor = bpy.context.active_object
    visor.name = f"{name}_visor"
    visor.scale = (1.5, 0.3, 0.4)
    bpy.ops.object.transform_apply(scale=True)
    mod = visor.modifiers.new("Bevel", 'BEVEL')
    mod.width = 0.01
    mod.segments = 3
    parts.append(visor)

    # Join all parts into one mesh
    bpy.ops.object.select_all(action='DESELECT')
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = torso
    bpy.ops.object.join()

    # Rename the joined object
    char_obj = bpy.context.active_object
    char_obj.name = name

    # Apply all modifiers
    for mod in char_obj.modifiers[:]:
        try:
            bpy.ops.object.modifier_apply(modifier=mod.name)
        except:
            char_obj.modifiers.remove(mod)

    # Center origin
    bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY', center='BOUNDS')

    # Move to ground level
    char_obj.location = (0, 0, 0)
    bbox = [char_obj.matrix_world @ Vector(corner) for corner in char_obj.bound_box]
    min_z = min(v.z for v in bbox)
    char_obj.location.z -= min_z

    return char_obj


def create_pbr_material(char_data, char_obj):
    """Create a PBR material with cyberpunk colors for the character."""
    mat_name = f"MAT_{char_data['id']}"
    mat = bpy.data.materials.new(name=mat_name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links

    # Clear default nodes
    for node in nodes:
        nodes.remove(node)

    # Create output node
    output = nodes.new('ShaderNodeOutputMaterial')
    output.location = (800, 0)

    # Create principled BSDF
    principled = nodes.new('ShaderNodeBsdfPrincipled')
    principled.location = (400, 0)
    links.new(principled.outputs['BSDF'], output.inputs['Surface'])

    # Set base color (mix of primary and skin)
    principled.inputs['Base Color'].default_value = char_data['color_primary']
    principled.inputs['Roughness'].default_value = 0.4
    principled.inputs['Metallic'].default_value = 0.3

    # Add emission for cyberpunk glow effect
    principled.inputs['Emission Color'].default_value = char_data['emission_color']
    principled.inputs['Emission Strength'].default_value = 0.5

    # Assign material to object
    if char_obj.data.materials:
        char_obj.data.materials[0] = mat
    else:
        char_obj.data.materials.append(mat)

    return mat


def smart_uv_unwrap(char_obj):
    """UV unwrap the character mesh."""
    bpy.context.view_layer.objects.active = char_obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')


def bake_pbr_textures(char_obj, char_data):
    """Bake PBR texture maps for the character."""
    tex_dir = os.path.join(TEXTURE_DIR, char_data['id'])
    os.makedirs(tex_dir, exist_ok=True)

    # Set render engine to Cycles for baking
    bpy.context.scene.render.engine = 'CYCLES'
    bpy.context.scene.cycles.device = 'CPU'
    bpy.context.scene.cycles.samples = 32

    # Select the character
    bpy.ops.object.select_all(action='DESELECT')
    char_obj.select_set(True)
    bpy.context.view_layer.objects.active = char_obj

    mat = char_obj.data.materials[0]
    nodes = mat.node_tree.nodes

    bake_passes = {
        'DIFFUSE': f"{char_data['id']}_diffuse.png",
        'ROUGHNESS': f"{char_data['id']}_roughness.png",
        'NORMAL': f"{char_data['id']}_normal.png",
        'EMIT': f"{char_data['id']}_emission.png",
    }

    for bake_type, filename in bake_passes.items():
        print(f"  Baking {bake_type} for {char_data['id']}...")

        # Create image for baking
        img_name = f"{char_data['id']}_{bake_type.lower()}"
        img = bpy.data.images.new(img_name, BAKE_RESOLUTION, BAKE_RESOLUTION)
        img.filepath_raw = os.path.join(tex_dir, filename)
        img.file_format = 'PNG'

        # Create image texture node for baking target
        tex_node = nodes.new('ShaderNodeTexImage')
        tex_node.name = "BakeTarget"
        tex_node.image = img
        tex_node.select = True
        nodes.active = tex_node

        # Bake
        try:
            if bake_type == 'NORMAL':
                bpy.ops.object.bake(type='NORMAL', use_clear=True)
            elif bake_type == 'DIFFUSE':
                bpy.ops.object.bake(type='DIFFUSE', use_clear=True, pass_filter={'COLOR'})
            elif bake_type == 'ROUGHNESS':
                bpy.ops.object.bake(type='ROUGHNESS', use_clear=True)
            elif bake_type == 'EMIT':
                bpy.ops.object.bake(type='EMIT', use_clear=True)

            # Save the image
            img.save_render(filepath=os.path.join(tex_dir, filename))
            print(f"    Saved: {filename}")
        except Exception as e:
            print(f"    Warning: Bake {bake_type} failed: {e}")
            # Create a fallback solid color image
            img.generated_color = char_data['color_primary'] if bake_type == 'DIFFUSE' else (0.5, 0.5, 1.0, 1.0)
            img.save_render(filepath=os.path.join(tex_dir, filename))
            print(f"    Saved fallback: {filename}")

        # Remove temp bake node
        nodes.remove(tex_node)

    return tex_dir


def export_glb(char_obj, char_data):
    """Export the character as GLB file."""
    output_path = os.path.join(OUTPUT_DIR, f"{char_data['id']}.glb")

    # Select only the character
    bpy.ops.object.select_all(action='DESELECT')
    char_obj.select_set(True)
    bpy.context.view_layer.objects.active = char_obj

    # Export as GLB
    bpy.ops.export_scene.gltf(
        filepath=output_path,
        use_selection=True,
        export_format='GLB',
        export_apply=True,
        export_materials='EXPORT',
        export_yup=True,
    )

    print(f"  Exported: {output_path}")
    return output_path


def generate_character(char_data):
    """Full pipeline for one character: generate, material, UV, bake, export."""
    print(f"\n{'='*60}")
    print(f"Generating character: {char_data['name']} ({char_data['id']})")
    print(f"{'='*60}")

    # Clear scene
    clear_scene()

    # Step 1: Create humanoid mesh
    print("  Step 1: Creating humanoid mesh...")
    char_obj = create_humanoid_mesh(char_data)
    print(f"    Created mesh with {len(char_obj.data.vertices)} vertices")

    # Step 2: UV Unwrap
    print("  Step 2: UV unwrapping...")
    smart_uv_unwrap(char_obj)

    # Step 3: Create PBR material
    print("  Step 3: Creating PBR material...")
    mat = create_pbr_material(char_data, char_obj)

    # Step 4: Bake PBR textures
    print("  Step 4: Baking PBR textures...")
    tex_dir = bake_pbr_textures(char_obj, char_data)

    # Step 5: Export as GLB
    print("  Step 5: Exporting GLB...")
    glb_path = export_glb(char_obj, char_data)

    print(f"  DONE: {char_data['name']} generated successfully!")
    return glb_path


def main():
    """Main entry point - generate all characters."""
    print("\n" + "="*60)
    print("CYBERPUNK CHARACTER GENERATION PIPELINE")
    print("="*60)

    # Ensure output directories exist
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(TEXTURE_DIR, exist_ok=True)

    results = []

    for char_data in CHARACTERS:
        try:
            glb_path = generate_character(char_data)
            results.append({
                "id": char_data["id"],
                "name": char_data["name"],
                "glb_path": glb_path,
                "region": char_data["region"],
                "success": True
            })
        except Exception as e:
            print(f"  ERROR generating {char_data['id']}: {e}")
            import traceback
            traceback.print_exc()
            results.append({
                "id": char_data["id"],
                "name": char_data["name"],
                "glb_path": None,
                "region": char_data["region"],
                "success": False
            })

    # Print summary
    print("\n" + "="*60)
    print("GENERATION SUMMARY")
    print("="*60)
    success_count = sum(1 for r in results if r["success"])
    print(f"  Generated: {success_count}/{len(CHARACTERS)} characters")
    for r in results:
        status = "OK" if r["success"] else "FAILED"
        print(f"    [{status}] {r['id']} -> {r['glb_path']}")

    # Write results file for registration step
    results_file = os.path.join(PROJECT_ROOT, "tools", "ai_asset_generation", "character_gen_results.json")
    import json
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\n  Results saved to: {results_file}")


if __name__ == "__main__":
    main()
