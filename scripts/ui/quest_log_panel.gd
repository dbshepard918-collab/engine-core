class_name QuestLogPanel
extends Control

@export var quest_list: VBoxContainer
@export var detail_title: Label
@export var detail_summary: RichTextLabel
@export var step_list: VBoxContainer
@export var quest_button_scene: PackedScene
@export var step_label_scene: PackedScene

var manager: QuestManager
var selected_quest_id := ""

func bind_quest_manager(qm: QuestManager) -> void:
    manager = qm
    manager.quest_updated.connect(rebuild)
    rebuild()

func rebuild() -> void:
    if manager == null: return
    for c in quest_list.get_children(): c.queue_free()
    for quest_id in manager.active_quests.keys():
        var q = manager.active_quests[quest_id]
        var b := quest_button_scene.instantiate() as Button
        b.text = q.definition.title
        b.pressed.connect(func(): select_quest(quest_id))
        quest_list.add_child(b)
    if selected_quest_id == "" and not manager.active_quests.is_empty():
        select_quest(manager.active_quests.keys()[0])

func select_quest(quest_id: String) -> void:
    selected_quest_id = quest_id
    var q: QuestInstance = manager.active_quests.get(quest_id)
    if q == null: return
    detail_title.text = q.definition.title
    detail_summary.bbcode_enabled = true
    detail_summary.text = q.definition.summary
    for c in step_list.get_children(): c.queue_free()
    for i in range(q.definition.steps.size()):
        var step: QuestStepDefinition = q.definition.steps[i]
        var label := step_label_scene.instantiate() as Label
        var done := q.completed_steps.has(i)
        label.text = ("✓ " if done else "□ ") + step.description
        step_list.add_child(label)
