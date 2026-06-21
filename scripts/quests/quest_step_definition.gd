class_name QuestStepDefinition
extends Resource

enum StepType { TALK_TO_NPC, KILL_ENEMY, COLLECT_ITEM, REACH_AREA, INTERACT_OBJECT, COMPLETE_EVENT }

@export var id: String
@export var description: String
@export var step_type: StepType
@export var target_id: String
@export var required_count: int = 1
@export var optional: bool = false
@export var objective_marker_scene: PackedScene
