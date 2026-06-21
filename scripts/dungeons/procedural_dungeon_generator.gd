class_name ProceduralDungeonGenerator
extends Node3D

signal dungeon_generated(dungeon_id: String)
signal room_spawned(room_type: String, position: Vector3)

@export var dungeon: DungeonDefinition
@export var seed_value: int = 0
@export var grid_spacing: float = 36.0
@export var room_container: Node3D
@export var navigation_region: NavigationRegion3D

var rng := RandomNumberGenerator.new()
var rooms: Dictionary = {} # Vector2i -> DungeonRoomNode

func generate() -> void:
    clear()
    rng.seed = seed_value if seed_value != 0 else hash(dungeon.id) + dungeon.seed_salt
    build_critical_path()
    add_branches()
    add_loops()
    tag_special_rooms()
    instantiate_rooms()
    bake_navigation()
    dungeon_generated.emit(dungeon.id)

func build_critical_path() -> void:
    var length := rng.randi_range(dungeon.min_rooms, dungeon.max_rooms)
    var pos := Vector2i.ZERO
    var last_dir := Vector2i.RIGHT
    for i in range(length):
        var room := create_room(pos, "normal")
        if i == 0: room.room_type = "entrance"
        elif i == length - 1: room.room_type = "boss"
        var dir := pick_direction(last_dir)
        var next := pos + dir
        connect_rooms(pos, next)
        pos = next
        last_dir = dir

func add_branches() -> void:
    var keys := rooms.keys()
    for k in keys:
        if rng.randf() > dungeon.branch_chance: continue
        var start: Vector2i = k
        var len := rng.randi_range(1, 4)
        var pos := start
        for i in range(len):
            var next := pos + random_cardinal()
            if rooms.has(next): break
            create_room(next, "normal")
            connect_rooms(pos, next)
            pos = next
        if rng.randf() < 0.5 and rooms.has(pos): rooms[pos].room_type = "treasure"

func add_loops() -> void:
    var keys := rooms.keys()
    for k in keys:
        if rng.randf() > dungeon.loop_chance: continue
        var a: Vector2i = k
        var b := a + random_cardinal()
        if rooms.has(b): connect_rooms(a, b)

func tag_special_rooms() -> void:
    var candidates := []
    for r in rooms.values():
        if r.room_type == "normal": candidates.append(r)
    candidates.shuffle()
    for i in range(min(dungeon.side_event_count, candidates.size())):
        candidates[i].room_type = "event"
    if candidates.size() > dungeon.side_event_count:
        candidates[dungeon.side_event_count].room_type = "objective"

func create_room(grid: Vector2i, room_type: String) -> DungeonRoomNode:
    if rooms.has(grid): return rooms[grid]
    var r := DungeonRoomNode.new()
    r.id = "%d_%d" % [grid.x, grid.y]
    r.grid = grid
    r.room_type = room_type
    rooms[grid] = r
    return r

func connect_rooms(a: Vector2i, b: Vector2i) -> void:
    var ra := create_room(a, "normal")
    var rb := create_room(b, "normal")
    if not ra.connections.has(b): ra.connections.append(b)
    if not rb.connections.has(a): rb.connections.append(a)

func instantiate_rooms() -> void:
    for r: DungeonRoomNode in rooms.values():
        var scene := pick_scene_for_room(r.room_type)
        if scene == null: continue
        var inst := scene.instantiate() as Node3D
        room_container.add_child(inst)
        inst.position = Vector3(r.grid.x * grid_spacing, 0, r.grid.y * grid_spacing)
        inst.set_meta("room_type", r.room_type)
        inst.set_meta("room_connections", r.connections)
        room_spawned.emit(r.room_type, inst.position)

func pick_scene_for_room(room_type: String) -> PackedScene:
    match room_type:
        "entrance": return dungeon.entrance_scene if dungeon.entrance_scene else random_room()
        "boss": return dungeon.boss_room_scene if dungeon.boss_room_scene else random_room()
        "objective":
            if not dungeon.objective_scene_pool.is_empty(): return dungeon.objective_scene_pool[rng.randi_range(0, dungeon.objective_scene_pool.size() - 1)]
            return random_room()
        "treasure": return dungeon.reward_chest_scene if dungeon.reward_chest_scene else random_room()
        _: return random_room()

func random_room() -> PackedScene:
    if dungeon.room_scene_pool.is_empty(): return null
    return dungeon.room_scene_pool[rng.randi_range(0, dungeon.room_scene_pool.size() - 1)]

func pick_direction(last_dir: Vector2i) -> Vector2i:
    var dirs := [last_dir, last_dir, Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
    return dirs[rng.randi_range(0, dirs.size() - 1)]

func random_cardinal() -> Vector2i:
    var dirs := [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]
    return dirs[rng.randi_range(0, dirs.size() - 1)]

func bake_navigation() -> void:
    if navigation_region:
        navigation_region.bake_navigation_mesh()

func clear() -> void:
    rooms.clear()
    for c in room_container.get_children(): c.queue_free()
