class_name QuestInstance
extends Resource

@export var definition: QuestDefinition
@export var current_step_index: int = 0
@export var progress: Dictionary = {}
@export var completed_steps: Array[int] = []
@export var is_completed: bool = false
@export var is_tracked: bool = false
