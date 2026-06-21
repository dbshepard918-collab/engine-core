class_name LootTable
extends Resource
@export var id: String
@export var entries: Array[Dictionary] = []
# Entry format: {"item_id":"pulse_blade", "weight":10.0, "min_level":1, "max_level":999}
@export var currency_min: int = 0
@export var currency_max: int = 0
@export var drop_chance: float = 1.0
