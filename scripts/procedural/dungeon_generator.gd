class_name DungeonGenerator
extends Node3D
@export var room_scenes: Array[PackedScene] = []
@export var corridor_scene: PackedScene
@export var max_rooms: int = 18
@export var grid_spacing: float = 28.0
@export var seed_value: int = 0
@export var critical_path_length: int = 8
var rng := RandomNumberGenerator.new()
var occupied := {}
var rooms := []
func generate() -> void:
    clear_existing(); rng.seed = seed_value if seed_value != 0 else randi(); occupied.clear(); rooms.clear()
    var start := Vector2i.ZERO; create_room(start, "start"); var cursor := start
    for i in range(critical_path_length):
        var next := find_free_neighbor(cursor)
        if next == Vector2i(999, 999): break
        create_room(next, "critical"); connect_rooms(cursor, next); cursor = next
    while rooms.size() < max_rooms:
        var anchor = rooms[rng.randi_range(0, rooms.size() - 1)].grid
        var branch := find_free_neighbor(anchor)
        if branch == Vector2i(999, 999): continue
        create_room(branch, "branch"); connect_rooms(anchor, branch)
    validate_generation()
func create_room(grid: Vector2i, kind: String) -> Node3D:
    var scene := room_scenes[rng.randi_range(0, room_scenes.size() - 1)]
    var room := scene.instantiate() as Node3D; add_child(room); room.position = Vector3(grid.x * grid_spacing, 0, grid.y * grid_spacing)
    room.set_meta("grid", grid); room.set_meta("kind", kind); occupied[grid] = room; rooms.append({"node": room, "grid": grid, "kind": kind}); return room
func connect_rooms(a: Vector2i, b: Vector2i) -> void:
    if corridor_scene == null: return
    var corridor := corridor_scene.instantiate() as Node3D; add_child(corridor)
    var pa := Vector3(a.x * grid_spacing, 0, a.y * grid_spacing); var pb := Vector3(b.x * grid_spacing, 0, b.y * grid_spacing)
    corridor.position = (pa + pb) * 0.5; corridor.look_at(pb, Vector3.UP); corridor.scale.z = pa.distance_to(pb) / grid_spacing
func find_free_neighbor(grid: Vector2i) -> Vector2i:
    var dirs := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]; dirs.shuffle()
    for d in dirs:
        var n = grid + d
        if not occupied.has(n): return n
    return Vector2i(999, 999)
func validate_generation() -> void:
    if rooms.size() < 3: push_warning("Dungeon generated very few rooms. Increase grid options or lower constraints.")
func clear_existing() -> void:
    for c in get_children(): c.queue_free()

