class_name PlayerSkillTree
extends Node

signal skill_points_changed(points: int)
signal node_rank_changed(node_id: String, rank: int)
signal skill_unlocked(skill_id: String)
signal passive_stats_changed(stats: StatBlock)

@export var tree_definition: SkillTreeDefinition
@export var player_level: int = 1
@export var available_points: int = 0

var ranks: Dictionary = {}

func can_purchase(node_id: String) -> bool:
    var node := tree_definition.get_node_def(node_id)
    if node == null: return false
    if player_level < node.required_player_level: return false
    var current := int(ranks.get(node_id, 0))
    if current >= node.max_rank: return false
    if available_points < node.cost_per_rank: return false
    for req in node.required_node_ids:
        if int(ranks.get(req, 0)) <= 0: return false
    for blocked in node.blocks_node_ids:
        if int(ranks.get(blocked, 0)) > 0: return false
    return true

func purchase(node_id: String) -> bool:
    if not can_purchase(node_id): return false
    var node := tree_definition.get_node_def(node_id)
    ranks[node_id] = int(ranks.get(node_id, 0)) + 1
    available_points -= node.cost_per_rank
    node_rank_changed.emit(node_id, ranks[node_id])
    skill_points_changed.emit(available_points)
    if node.is_active_skill() and ranks[node_id] == 1:
        skill_unlocked.emit(node.skill_id)
    passive_stats_changed.emit(calculate_passive_stats())
    return true

func refund(node_id: String) -> bool:
    if int(ranks.get(node_id, 0)) <= 0: return false
    if has_dependents(node_id): return false
    var node := tree_definition.get_node_def(node_id)
    ranks[node_id] -= 1
    available_points += node.cost_per_rank
    node_rank_changed.emit(node_id, ranks[node_id])
    skill_points_changed.emit(available_points)
    passive_stats_changed.emit(calculate_passive_stats())
    return true

func has_dependents(node_id: String) -> bool:
    for n in tree_definition.nodes:
        if n.required_node_ids.has(node_id) and int(ranks.get(n.id, 0)) > 0:
            return true
    return false

func calculate_passive_stats() -> StatBlock:
    var total := StatBlock.new()
    for node_id in ranks.keys():
        var node := tree_definition.get_node_def(node_id)
        if node and node.stat_bonus_per_rank:
            for i in range(int(ranks[node_id])):
                total.add(node.stat_bonus_per_rank)
    return total
