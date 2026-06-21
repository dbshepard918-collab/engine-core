class_name QuestManager
extends Node

signal quest_started(quest_id: String)
signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)
signal objective_marker_requested(target_id: String)

@export var quest_database: Array[QuestDefinition] = []
var quests_by_id := {}
var active_quests: Dictionary = {}
var completed_quests: Dictionary = {}

func _ready() -> void:
    for q in quest_database:
        quests_by_id[q.id] = q
    EventBus.enemy_killed.connect(_on_enemy_killed)

func can_start(quest_id: String) -> bool:
    var q: QuestDefinition = quests_by_id.get(quest_id)
    if q == null: return false
    if active_quests.has(quest_id) or completed_quests.has(quest_id): return false
    for prereq in q.prerequisite_quest_ids:
        if not completed_quests.has(prereq): return false
    return true

func start_quest(quest_id: String) -> bool:
    if not can_start(quest_id): return false
    var inst = QuestInstance.new()
    inst.definition = quests_by_id[quest_id]
    inst.progress = {}
    active_quests[quest_id] = inst
    quest_started.emit(quest_id)
    quest_updated.emit(quest_id)
    request_marker_for_current_step(inst)
    return true

func add_progress(step_type: int, target_id: String, amount: int = 1) -> void:
    for quest_id in active_quests.keys():
        var inst: QuestInstance = active_quests[quest_id]
        if inst.is_completed or inst.current_step_index >= inst.definition.steps.size(): continue
        var step: QuestStepDefinition = inst.definition.steps[inst.current_step_index]
        if step.step_type == step_type and step.target_id == target_id:
            var key := str(inst.current_step_index)
            inst.progress[key] = int(inst.progress.get(key, 0)) + amount
            if int(inst.progress[key]) >= step.required_count:
                complete_step(inst)
            quest_updated.emit(quest_id)

func complete_step(inst: QuestInstance) -> void:
    if not inst.completed_steps.has(inst.current_step_index):
        inst.completed_steps.append(inst.current_step_index)
    inst.current_step_index += 1
    if inst.current_step_index >= inst.definition.steps.size():
        complete_quest(inst.definition.id)
    else:
        request_marker_for_current_step(inst)

func complete_quest(quest_id: String) -> void:
    var inst: QuestInstance = active_quests.get(quest_id)
    if inst == null: return
    inst.is_completed = true
    active_quests.erase(quest_id)
    completed_quests[quest_id] = true
    grant_rewards(inst.definition)
    quest_completed.emit(quest_id)
    for follow in inst.definition.followup_quest_ids:
        if can_start(follow): start_quest(follow)

func grant_rewards(q: QuestDefinition) -> void:
    EventBus.ui_toast_requested.emit("Quest complete: " + q.title, "quest")
    # Connect this to XP, currency, and inventory systems in the game runtime bootstrap.

func request_marker_for_current_step(inst: QuestInstance) -> void:
    var step: QuestStepDefinition = inst.definition.steps[inst.current_step_index]
    objective_marker_requested.emit(step.target_id)

func _on_enemy_killed(enemy: Node, payload: Dictionary) -> void:
    var enemy_id = enemy.get("enemy_id") if "enemy_id" in enemy else enemy.name
    add_progress(QuestStepDefinition.StepType.KILL_ENEMY, str(enemy_id), 1)
