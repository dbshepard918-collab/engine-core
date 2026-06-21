class_name DungeonEntranceActor
extends Area3D

signal entrance_activated(dungeon_id: String)

@export var dungeon_id: String
@export var display_name_key: String
@export var required_level: int = 1
@export var locked_by_story_flag: String = ""
@export var interaction_prompt_key: String = "ENTER_DUNGEON"

var player_in_range := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
    if player_in_range and event.is_action_pressed("interact"):
        activate()

func activate() -> void:
    entrance_activated.emit(dungeon_id)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = true
        EventBus.ui_toast_requested.emit(tr(interaction_prompt_key) + ": " + tr(display_name_key), "interaction")

func _on_body_exited(body: Node) -> void:
    if body.is_in_group("player"):
        player_in_range = false
