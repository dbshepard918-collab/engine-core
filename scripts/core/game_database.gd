extends Node

var items: Dictionary = {}
var skills: Dictionary = {}
var enemies: Dictionary = {}
var loot_tables: Dictionary = {}

func _ready() -> void:
    load_folder("res://data/items", items)
    load_folder("res://data/skills", skills)
    load_folder("res://data/enemies", enemies)
    load_folder("res://data/loot_tables", loot_tables)
    validate_database()

func load_folder(path: String, target: Dictionary) -> void:
    var dir := DirAccess.open(path)
    if dir == null:
        push_warning("Database folder missing: " + path)
        return
    dir.list_dir_begin()
    var file := dir.get_next()
    while file != "":
        if not dir.current_is_dir() and (file.ends_with(".tres") or file.ends_with(".res")):
            var res := load(path + "/" + file)
            if res != null and "id" in res:
                if target.has(res.id): push_error("Duplicate database id: " + str(res.id))
                target[res.id] = res
        file = dir.get_next()
    dir.list_dir_end()

func get_item(id: String) -> Resource: return items.get(id)
func get_skill(id: String) -> Resource: return skills.get(id)

func validate_database() -> void:
    for id in items.keys():
        if id == "": push_error("Item has empty id")
    for id in skills.keys():
        if skills[id].cooldown < 0: push_error("Skill has negative cooldown: " + id)

