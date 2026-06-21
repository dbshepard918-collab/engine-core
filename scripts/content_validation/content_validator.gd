@tool
class_name ContentValidator
extends EditorScript

var errors: Array[String] = []

func _run() -> void:
    errors.clear()
    validate_resources("res://data/items")
    validate_resources("res://data/skills")
    validate_enemy_scenes("res://scenes/actors/enemies")
    if errors.is_empty():
        print("Content validation passed.")
    else:
        push_error("Content validation failed: " + str(errors.size()) + " errors")
        for e in errors: push_error(e)

func validate_resources(path: String) -> void:
    var dir := DirAccess.open(path)
    if dir == null:
        errors.append("Missing folder: " + path)
        return
    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if file.ends_with(".tres") or file.ends_with(".res"):
            var res := load(path + "/" + file)
            if res == null:
                errors.append("Cannot load resource: " + path + "/" + file)
            elif "id" in res and res.id == "":
                errors.append("Resource has empty id: " + path + "/" + file)
        file = dir.get_next()
    dir.list_dir_end()

func validate_enemy_scenes(path: String) -> void:
    # Production version should recursively inspect scenes for HealthComponent, Hurtbox, NavigationAgent3D, and collision layers.
    print("Enemy scene validation hook: " + path)
