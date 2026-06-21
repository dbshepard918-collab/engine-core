@tool
extends EditorScript

## Run from Godot editor after GLB files are imported.
## This creates inherited tile scenes that are easier to script, decorate, and validate.

const SOURCE_FOLDER := "res://assets/meshes/tiles/lower_grid"
const OUT_FOLDER := "res://scenes/tiles/lower_grid"

func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_FOLDER))
    var dir := DirAccess.open(SOURCE_FOLDER)
    if dir == null:
        push_error("Missing source folder: " + SOURCE_FOLDER)
        return
    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if file.ends_with(".glb") or file.ends_with(".gltf"):
            create_tile_scene(SOURCE_FOLDER + "/" + file, file.get_basename())
        file = dir.get_next()
    dir.list_dir_end()
    print("Tile scene post-import pass complete.")

func create_tile_scene(src: String, id: String) -> void:
    var packed := load(src) as PackedScene
    if packed == null:
        push_warning("Could not load " + src)
        return
    var root := Node3D.new()
    root.name = id
    var inst := packed.instantiate()
    inst.name = "VisualRoot"
    root.add_child(inst)
    inst.owner = root
    root.set_meta("tile_id", id)
    root.set_meta("tile_pipeline", "v6_blender_to_godot")
    var out_path := OUT_FOLDER + "/" + id + ".tscn"
    var out := PackedScene.new()
    out.pack(root)
    ResourceSaver.save(out, out_path)
    root.free()
    print("Created tile scene: " + out_path)
