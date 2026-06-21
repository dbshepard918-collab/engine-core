class_name NPCActor
extends Node3D

@export var npc_id: String
@export var display_name: String
@export var dialogue_graph: DialogueGraphDefinition
@export var interaction_area: Area3D
@export var quest_marker: Node3D

var player_in_range := false
var dialogue_manager: DialogueManager

func _ready() -> void:
    interaction_area.body_entered.connect(_on_body_entered)
    interaction_area.body_exited.connect(_on_body_exited)

func bind_dialogue_manager(dm: DialogueManager) -> void:
    dialogue_manager = dm

func _unhandled_input(event: InputEvent) -> void:
    if player_in_range and event.is_action_pressed("interact"):
        interact()

func interact() -> void:
    if dialogue_manager and dialogue_graph:
        dialogue_manager.start_dialogue(dialogue_graph)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = true
        EventBus.ui_toast_requested.emit("Press E to talk: " + display_name, "interaction")

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = false
