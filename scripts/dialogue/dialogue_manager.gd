class_name DialogueManager
extends Node

signal dialogue_started(graph_id: String)
signal dialogue_line_changed(node: DialogueNodeDefinition)
signal dialogue_choices_changed(choices: Array[DialogueChoice])
signal dialogue_finished(graph_id: String)

@export var quest_manager: QuestManager
var current_graph: DialogueGraphDefinition
var current_node: DialogueNodeDefinition
var flags := {}

func start_dialogue(graph: DialogueGraphDefinition) -> void:
    if graph == null: return
    current_graph = graph
    dialogue_started.emit(graph.id)
    go_to_node(graph.start_node_id)

func go_to_node(node_id: String) -> void:
    if current_graph == null: return
    current_node = current_graph.get_node_def(node_id)
    if current_node == null:
        finish_dialogue()
        return
    dialogue_line_changed.emit(current_node)
    dialogue_choices_changed.emit(get_available_choices(current_node))

func choose(choice: DialogueChoice) -> void:
    if choice == null: return
    if choice.set_flag != "": flags[choice.set_flag] = true
    if choice.starts_quest_id != "" and quest_manager:
        quest_manager.start_quest(choice.starts_quest_id)
    if choice.completes_step_target_id != "" and quest_manager:
        quest_manager.add_progress(QuestStepDefinition.StepType.TALK_TO_NPC, choice.completes_step_target_id, 1)
    if choice.next_node_id == "": finish_dialogue()
    else: go_to_node(choice.next_node_id)

func get_available_choices(node: DialogueNodeDefinition) -> Array[DialogueChoice]:
    var out: Array[DialogueChoice] = []
    for c in node.choices:
        if c.required_quest_id != "" and quest_manager and not quest_manager.active_quests.has(c.required_quest_id):
            continue
        if c.condition_flag != "" and not bool(flags.get(c.condition_flag, false)):
            continue
        out.append(c)
    return out

func finish_dialogue() -> void:
    var graph_id := current_graph.id if current_graph else ""
    current_graph = null
    current_node = null
    dialogue_finished.emit(graph_id)
