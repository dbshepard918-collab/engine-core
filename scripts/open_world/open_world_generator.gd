class_name OpenWorldGenerator
extends Node3D

signal world_generated(region_id: String)
signal poi_placed(poi_id: String, position: Vector3)
signal dungeon_entrance_placed(dungeon_id: String, position: Vector3)

@export var region: WorldRegionDefinition
@export var seed_value: int = 0
@export var player_start_marker: Node3D
@export var navigation_region: NavigationRegion3D
@export var poi_container: Node3D
@export var terrain_container: Node3D
@export var road_container: Node3D

var rng := RandomNumberGenerator.new()
var nodes: Dictionary = {} # Vector2i -> WorldNode
var placed_pois: Array[Dictionary] = []

func generate() -> void:
    clear_world()
    rng.seed = seed_value if seed_value != 0 else hash(region.id) + region.seed_salt
    build_world_graph()
    carve_primary_routes()
    instantiate_terrain()
    place_required_pois()
    place_weighted_pois()
    place_dungeon_entrances()
    apply_navigation()
    world_generated.emit(region.id)

func build_world_graph() -> void:
    for y in range(region.world_size_cells.y):
        for x in range(region.world_size_cells.x):
            var n := WorldNode.new()
            n.grid = Vector2i(x, y)
            n.world_position = Vector3(x * region.cell_size, 0, y * region.cell_size)
            if x == 0 or y == 0 or x == region.world_size_cells.x - 1 or y == region.world_size_cells.y - 1:
                n.tags.append("boundary")
            elif rng.randf() < 0.08:
                n.tags.append("blocker")
            else:
                n.tags.append("walkable")
            n.difficulty_bias = float(y) / maxf(1.0, region.world_size_cells.y)
            nodes[n.grid] = n

func carve_primary_routes() -> void:
    var center_y := int(region.world_size_cells.y / 2)
    for x in range(2, region.world_size_cells.x - 2):
        mark_walkable(Vector2i(x, center_y))
        if x % 6 == 0:
            var branch_dir := -1 if rng.randf() < 0.5 else 1
            for k in range(1, rng.randi_range(5, 12)):
                mark_walkable(Vector2i(x, clampi(center_y + k * branch_dir, 2, region.world_size_cells.y - 3)))

func mark_walkable(g: Vector2i) -> void:
    if not nodes.has(g): return
    var n: WorldNode = nodes[g]
    n.tags.erase("blocker")
    if not n.tags.has("walkable"): n.tags.append("walkable")
    if not n.tags.has("road"): n.tags.append("road")

func instantiate_terrain() -> void:
    for g in nodes.keys():
        var n: WorldNode = nodes[g]
        var pool := region.boundary_scene_pool if n.has_tag("boundary") or n.has_tag("blocker") else region.tile_scene_pool
        if n.has_tag("road") and not region.road_scene_pool.is_empty(): pool = region.road_scene_pool
        if pool.is_empty(): continue
        var scene := pool[rng.randi_range(0, pool.size() - 1)]
        var inst := scene.instantiate() as Node3D
        terrain_container.add_child(inst)
        inst.position = n.world_position

func place_required_pois() -> void:
    place_type(POIDefinition.POIType.TOWN_HUB, 1)
    place_type(POIDefinition.POIType.FAST_TRAVEL, 2)
    place_type(POIDefinition.POIType.STRONGHOLD, region.stronghold_count)
    place_type(POIDefinition.POIType.WORLD_EVENT, region.world_event_count)

func place_type(poi_type: int, count: int) -> void:
    var candidates: Array[POIDefinition] = []
    for p in region.poi_pool:
        if p.poi_type == poi_type: candidates.append(p)
    for i in range(count):
        if candidates.is_empty(): return
        var poi := weighted_poi(candidates)
        var node := find_poi_node(poi)
        if node: instantiate_poi(poi, node)

func place_weighted_pois() -> void:
    var total_count := rng.randi_range(region.min_poi_count, region.max_poi_count)
    var safety := 0
    while placed_pois.size() < total_count and safety < total_count * 20:
        safety += 1
        var poi := weighted_poi(region.poi_pool)
        if poi == null or poi.poi_type == POIDefinition.POIType.DUNGEON_ENTRANCE: continue
        var node := find_poi_node(poi)
        if node: instantiate_poi(poi, node)

func place_dungeon_entrances() -> void:
    var dungeons := []
    for p in region.poi_pool:
        if p.poi_type == POIDefinition.POIType.DUNGEON_ENTRANCE:
            dungeons.append(p)
    for i in range(region.dungeon_entrance_count):
        if dungeons.is_empty(): return
        var poi: POIDefinition = weighted_poi(dungeons)
        var node := find_poi_node(poi)
        if node:
            instantiate_poi(poi, node)
            dungeon_entrance_placed.emit(poi.attached_dungeon_id, node.world_position)

func weighted_poi(pool: Array) -> POIDefinition:
    if pool.is_empty(): return null
    var total := 0.0
    for p in pool: total += maxf(0.01, p.weight)
    var roll := rng.randf_range(0.0, total)
    var run := 0.0
    for p in pool:
        run += maxf(0.01, p.weight)
        if roll <= run: return p
    return pool[0]

func find_poi_node(poi: POIDefinition) -> WorldNode:
    var tries := 0
    while tries < 300:
        tries += 1
        var g := Vector2i(rng.randi_range(3, region.world_size_cells.x - 4), rng.randi_range(3, region.world_size_cells.y - 4))
        var n: WorldNode = nodes.get(g)
        if n == null or n.occupied or not n.has_tag("walkable"): continue
        if too_close_to_same_type(n.world_position, poi): continue
        return n
    return null

func too_close_to_same_type(pos: Vector3, poi: POIDefinition) -> bool:
    for entry in placed_pois:
        if entry.type == poi.poi_type and pos.distance_to(entry.position) < poi.min_distance_from_same_type:
            return true
    return false

func instantiate_poi(poi: POIDefinition, n: WorldNode) -> void:
    if poi.scene == null: return
    var inst := poi.scene.instantiate() as Node3D
    poi_container.add_child(inst)
    inst.position = n.world_position
    n.occupied = true
    n.poi_id = poi.id
    placed_pois.append({"id": poi.id, "type": poi.poi_type, "position": n.world_position})
    poi_placed.emit(poi.id, n.world_position)

func apply_navigation() -> void:
    if navigation_region:
        navigation_region.bake_navigation_mesh()

func clear_world() -> void:
    nodes.clear()
    placed_pois.clear()
    for c in terrain_container.get_children(): c.queue_free()
    for c in road_container.get_children(): c.queue_free()
    for c in poi_container.get_children(): c.queue_free()
