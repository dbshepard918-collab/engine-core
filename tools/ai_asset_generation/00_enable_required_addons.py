# Run inside Blender: Text Editor > Open > Run Script
# Purpose: Enable the built-in add-ons used by this pipeline.
# Notes: Blender's glTF 2.0 add-on is usually enabled by default, but this script enables it if needed.

import bpy

REQUIRED_ADDONS = [
    "io_scene_gltf2",   # glTF 2.0 import/export
    "node_wrangler",    # Material/node workflow helper if available
]

for addon in REQUIRED_ADDONS:
    try:
        bpy.ops.preferences.addon_enable(module=addon)
        print(f"Enabled add-on: {addon}")
    except Exception as exc:
        print(f"WARNING: Could not enable add-on {addon}: {exc}")

try:
    bpy.ops.wm.save_userpref()
    print("Saved Blender user preferences.")
except Exception as exc:
    print(f"WARNING: Could not save preferences: {exc}")
