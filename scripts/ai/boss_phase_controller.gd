class_name BossPhaseController
extends Node
signal phase_changed(phase_index: int)
@export var health: HealthComponent
@export var ability_controller: AbilityController
@export var phase_thresholds: Array[float] = [0.70, 0.40, 0.15]
@export var phase_skill_sets: Array[Array] = []
@export var add_spawn_scene: PackedScene
@export var add_spawn_points: Array[NodePath] = []
var current_phase := 0
var triggered := {}
func _ready() -> void:
    if health: health.health_changed.connect(_on_health_changed)
func _on_health_changed(current: float, maximum: float) -> void:
    var pct := current / maximum
    for i in range(phase_thresholds.size()):
        if pct <= phase_thresholds[i] and not triggered.has(i): triggered[i] = true; enter_phase(i + 1)
func enter_phase(phase: int) -> void:
    current_phase = phase
    if ability_controller and phase - 1 < phase_skill_sets.size():
        ability_controller.skill_slots.clear()
        for skill_id in phase_skill_sets[phase - 1]:
            var s := GameDatabase.get_skill(str(skill_id))
            if s: ability_controller.skill_slots.append(s)
    spawn_add_wave(phase); phase_changed.emit(phase)
func spawn_add_wave(phase: int) -> void:
    if add_spawn_scene == null: return
    for i in range(phase * 2):
        if add_spawn_points.is_empty(): break
        var sp := get_node_or_null(add_spawn_points[i % add_spawn_points.size()]) as Node3D
        if sp == null: continue
        var add := add_spawn_scene.instantiate(); get_tree().current_scene.add_child(add); add.global_position = sp.global_position

