import bpy
from mathutils import Vector
from pathlib import Path

GRID = 4.0
HEIGHT = 3.0
OUT = Path("C:/Users/dbshe/OneDrive/Documents/engine-core/assets/meshes/tiles/lower_grid")
OUT.mkdir(parents=True, exist_ok=True)

def cube(name, loc, scale, mat_name):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    mat = bpy.data.materials.get(mat_name) or bpy.data.materials.new(mat_name)
    obj.data.materials.append(mat)
    return obj

def make_floor_tile(name):
    bpy.ops.object.select_all(action='DESELECT')
    floor = cube(name, (0, -0.05, 0), (GRID, 0.1, GRID), 'mat_floor_placeholder')
    floor.select_set(True)
    bpy.context.view_layer.objects.active = floor
    bpy.ops.export_scene.gltf(filepath=str(OUT / f"{name}.glb"), export_format='GLB', use_selection=True, export_apply=True)

def make_wall_tile(name, side='north'):
    bpy.ops.object.select_all(action='DESELECT')
    floor = cube(name + '_floor', (0, -0.05, 0), (GRID, 0.1, GRID), 'mat_floor_placeholder')
    wall_z = -GRID/2 if side == 'north' else GRID/2
    wall = cube(name + '_wall', (0, HEIGHT/2, wall_z), (GRID, HEIGHT, 0.25), 'mat_wall_placeholder')
    for o in [floor, wall]: o.select_set(True)
    bpy.context.view_layer.objects.active = floor
    bpy.ops.export_scene.gltf(filepath=str(OUT / f"{name}.glb"), export_format='GLB', use_selection=True, export_apply=True)

make_floor_tile('floor_plain_4m')
make_floor_tile('floor_grate_4m')
make_wall_tile('wall_neon_north_4m', 'north')
make_wall_tile('wall_service_south_4m', 'south')
print('Generated blockout GLB tiles.')
