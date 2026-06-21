extends Node

signal damage_event(payload: Dictionary)
signal enemy_killed(enemy: Node, payload: Dictionary)
signal item_dropped(item_stack: Resource, world_position: Vector3)
signal player_level_changed(level: int)
signal ui_toast_requested(message: String, style: String)
signal encounter_started(encounter_id: String)
signal encounter_completed(encounter_id: String)

func emit_damage(payload: Dictionary) -> void:
    damage_event.emit(payload)

func emit_enemy_killed(enemy: Node, payload: Dictionary) -> void:
    enemy_killed.emit(enemy, payload)

func emit_item_dropped(item_stack: Resource, world_position: Vector3) -> void:
    item_dropped.emit(item_stack, world_position)
