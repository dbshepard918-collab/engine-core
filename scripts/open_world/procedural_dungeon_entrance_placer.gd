class_name ProceduralDungeonEntrancePlacer
extends Node

signal entrance_instance_placed(entrance_id: String, dungeon_id: String, position: Vector3)

@export var entrance_definitions: Array[ProceduralDungeonEntranceDefinition] = []
@export var entrance_container: Node3D
@export var campaign_state: CampaignState
@export var faction_manager: FactionManager
@export var player_level: int = 1
@export var max_entrances_per_region: int = 6

var rng := RandomNumberGenerator.new()

func place_on_sockets(region_root: Node3D, seed_value: int = 0) -> void:
    rng.seed = seed_value if seed_value != 0 else randi()
    var sockets := collect_sockets(region_root)
    var placed := 0
    for socket in sockets:
        if placed >= max_entrances_per_region: break
        var def := pick_definition_for_socket(socket)
        if def == null: continue
        instantiate_entrance(def, socket)
        socket.occupied = true
        placed += 1

func collect_sockets(root: Node3D) -> Array[PlacementSocket]:
    var out: Array[PlacementSocket] = []
    for node in root.find_children("*", "PlacementSocket", true, false):
        var socket := node as PlacementSocket
        if socket and not socket.occupied and (socket.has_tag("dungeon_main") or socket.has_tag("dungeon_side") or socket.has_tag("boss_gate")):
            out.append(socket)
    out.shuffle()
    return out

func pick_definition_for_socket(socket: PlacementSocket) -> ProceduralDungeonEntranceDefinition:
    var candidates: Array[ProceduralDungeonEntranceDefinition] = []
    for def in entrance_definitions:
        if not can_use_definition(def): continue
        if socket.has_tag(def.socket_tag): candidates.append(def)
    if candidates.is_empty(): return null
    return candidates[rng.randi_range(0, candidates.size() - 1)]

func can_use_definition(def: ProceduralDungeonEntranceDefinition) -> bool:
    if def == null or def.scene == null or def.dungeon_definition == null: return false
    if player_level < def.min_player_level: return false
    if def.required_campaign_flag != "" and campaign_state and not bool(campaign_state.global_flags.get(def.required_campaign_flag, false)):
        return false
    if def.required_faction_id != "" and faction_manager and faction_manager.get_rank(def.required_faction_id) < def.required_faction_rank:
        return false
    return true

func instantiate_entrance(def: ProceduralDungeonEntranceDefinition, socket: PlacementSocket) -> void:
    var inst := def.scene.instantiate() as Node3D
    entrance_container.add_child(inst)
    inst.global_transform = socket.global_transform
    if inst is DungeonEntranceActor:
        inst.dungeon_id = def.get_dungeon_id()
        inst.display_name_key = def.display_name_key
        inst.required_level = def.min_player_level
    if def.light_profile and inst.has_node("TileDynamicLightSpawner"):
        inst.get_node("TileDynamicLightSpawner").profile = def.light_profile
    entrance_instance_placed.emit(def.id, def.get_dungeon_id(), inst.global_position)
