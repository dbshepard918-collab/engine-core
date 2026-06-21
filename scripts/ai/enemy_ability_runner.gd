class_name EnemyAbilityRunner
extends Node

@export var enemy: EnemyController
@export var abilities: Array[SkillDefinition] = []
@export var ability_controller: AbilityController
@export var min_time_between_abilities: float = 1.5

var timer := 0.0
var rng := RandomNumberGenerator.new()

func _process(delta: float) -> void:
    if enemy == null or enemy.target == null: return
    timer -= delta
    if timer > 0.0: return
    var usable := get_usable_abilities()
    if usable.is_empty(): return
    var skill := usable[rng.randi_range(0, usable.size() - 1)]
    ability_controller.cast(skill)
    timer = min_time_between_abilities + rng.randf_range(0.0, 1.0)

func get_usable_abilities() -> Array[SkillDefinition]:
    var out: Array[SkillDefinition] = []
    for a in abilities:
        if a == null: continue
        var d := enemy.global_position.distance_to(enemy.target.global_position)
        if d <= a.range:
            out.append(a)
    return out
