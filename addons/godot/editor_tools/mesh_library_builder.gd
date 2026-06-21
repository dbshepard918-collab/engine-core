@tool
extends EditorScript

## Builds a MeshLibrary from tile scenes. This keeps GridMap tile IDs stable.
## Run after tile_scene_post_import.gd.

const TILE_SCENE_FOLDER := "res://scenes/tiles/lower_grid"
const OUT_PATH := "res://data/tile_sets/lower_grid_mesh_library.tres"

func _run() -> void:
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://data/tile_sets"))
    var lib := MeshLibrary.new()
    var dir := DirAccess.open(TILE_SCENE_FOLDER)
    if dir == null:
        push_error("Missing tile scene folder: " + TILE_SCENE_FOLDER)
        return
    var id := 0
    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if file.ends_with(".tscn"):
            var scene_path := TILE_SCENE_FOLDER + "/" + file
            var scene := load(scene_path) as PackedScene
            var inst := scene.instantiate() as Node3D
            var mesh := find_first_mesh(inst)
            if mesh:
                lib.create_item(id)
                lib.set_item_name(id, file.get_basename())
                lib.set_item_mesh(id, mesh.mesh)
                var shapes := collect_collision_shapes(inst)
                if not shapes.is_empty():
                    lib.set_item_shapes(id, shapes)
                id += 1
            inst.free()
        file = dir.get_next()
    dir.list_dir_end()
    ResourceSaver.save(lib, OUT_PATH)
    print("Saved MeshLibrary: " + OUT_PATH + " items=" + str(id))

func find_first_mesh(n: Node) -> MeshInstance3D:
    if n is MeshInstance3D: return n
    for c in n.get_children():
        var found := find_first_mesh(c)
        if found: return found
    return null

func collect_collision_shapes(root: Node) -> Array:
    var out := []
    for node in root.find_children("*", "CollisionShape3D", true, false):
        var cs := node as CollisionShape3D
        if cs and cs.shape:
            out.append({"shape": cs.shape, "transform": cs.transform})
    return out
