import bpy
import sys

errors = []
MAX_TRIANGLES_WARNING = 60000

def fail(msg):
    errors.append(msg)

for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        if obj.scale.x != 1 or obj.scale.y != 1 or obj.scale.z != 1:
            fail(f"{obj.name}: unapplied scale {obj.scale}")
        if obj.data.polygons:
            tris = sum(len(poly.vertices) - 2 for poly in obj.data.polygons)
            if tris > MAX_TRIANGLES_WARNING:
                fail(f"{obj.name}: high triangle count {tris}")
        if not obj.data.materials:
            fail(f"{obj.name}: missing material")
        if any(slot.material and 'Material' in slot.material.name for slot in obj.material_slots):
            fail(f"{obj.name}: material has placeholder name")

for arm in [o for o in bpy.context.scene.objects if o.type == 'ARMATURE']:
    if arm.animation_data and arm.animation_data.nla_tracks:
        for track in arm.animation_data.nla_tracks:
            if track.name.strip() == "": fail(f"{arm.name}: empty NLA track name")

if errors:
    print("VALIDATION FAILED")
    for e in errors: print(" -", e)
    sys.exit(1)
else:
    print("VALIDATION PASSED")
