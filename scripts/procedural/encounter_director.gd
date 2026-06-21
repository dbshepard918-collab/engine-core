class_name EncounterDirector
extends Node
@export var enemy_scenes: Array[PackedScene] = []
@export var elite_scene: PackedScene
@export var player_level: int = 1
@export var base_budget: float = 10.0
@export var budget_per_level: float = 2.5
var rng := RandomNumberGenerator.new()
func spawn_encounter(room: Node3D, spawn_points: Array[Node3D], intensity: float) -> void:
    rng.randomize(); var budget := (base_budget + player_level * budget_per_level) * intensity
    while budget > 0.0 and not spawn_points.is_empty():
        var scene := choose_enemy_scene(budget); var cost := get_enemy_cost(scene)
        if cost > budget: break
        var sp := spawn_points[rng.randi_range(0, spawn_points.size() - 1)]
        var e := scene.instantiate() as Node3D; room.add_child(e); e.global_position = sp.global_position; budget -= cost
func choose_enemy_scene(budget: float) -> PackedScene:
    if elite_scene and budget > 8.0 and rng.randf() < 0.12: return elite_scene
    return enemy_scenes[rng.randi_range(0, enemy_scenes.size() - 1)]
func get_enemy_cost(scene: PackedScene) -> float: return 8.0 if scene == elite_scene else 2.0

