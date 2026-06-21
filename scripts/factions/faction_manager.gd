extends Node

signal reputation_changed(faction_id: String, value: int, delta: int)
signal faction_rank_changed(faction_id: String, rank: int)

@export var definitions: Array[FactionDefinition] = []
var defs := {}
var states: Dictionary = {}

func _ready() -> void:
    for d in definitions:
        defs[d.id] = d
        if not states.has(d.id):
            var s := FactionState.new(); s.faction_id = d.id; states[d.id] = s

func add_reputation(faction_id: String, delta: int, reason: String = "") -> void:
    var state: FactionState = states.get(faction_id)
    if state == null: return
    var old_rank := get_rank(faction_id)
    state.reputation = clampi(state.reputation + delta, -100, 100)
    reputation_changed.emit(faction_id, state.reputation, delta)
    var new_rank := get_rank(faction_id)
    if new_rank != old_rank:
        faction_rank_changed.emit(faction_id, new_rank)
    apply_relationship_splash(faction_id, delta)

func apply_relationship_splash(faction_id: String, delta: int) -> void:
    var d: FactionDefinition = defs.get(faction_id)
    if d == null: return
    for hostile in d.hostile_to_faction_ids:
        var s: FactionState = states.get(hostile)
        if s: s.reputation = clampi(s.reputation - int(delta * 0.5), -100, 100)
    for ally in d.allied_faction_ids:
        var s2: FactionState = states.get(ally)
        if s2: s2.reputation = clampi(s2.reputation + int(delta * 0.25), -100, 100)

func get_rank(faction_id: String) -> int:
    var d: FactionDefinition = defs.get(faction_id)
    var s: FactionState = states.get(faction_id)
    if d == null or s == null: return 2
    var rank := 0
    for i in range(d.rank_thresholds.size()):
        if s.reputation >= d.rank_thresholds[i]: rank = i
    return rank

func has_access(faction_id: String, required_rank: int) -> bool:
    return get_rank(faction_id) >= required_rank
