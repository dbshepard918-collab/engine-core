class_name FactionState
extends Resource

@export var faction_id: String
@export var reputation: int = 0
@export var discovered: bool = false
@export var completed_contracts: Array[String] = []
@export var flags: Dictionary = {}
