class_name AffixDefinition
extends Resource

@export var id: String
@export var display_name_pattern: String = "+{value} {stat}"
@export var group_id: String
@export var stat_name: String
@export var min_value: float
@export var max_value: float
@export var weight: float = 1.0
@export var min_item_level: int = 1
@export var rarities: Array[int] = []
@export var tags: Array[String] = []

func roll(rng: RandomNumberGenerator) -> Dictionary:
    var value := rng.randf_range(min_value, max_value)
    return {"affix_id": id, "stat_name": stat_name, "value": value, "text": display_name_pattern.format({"value": snapped(value, 0.1), "stat": stat_name})}
