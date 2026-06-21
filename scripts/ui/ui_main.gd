class_name UIMain
extends CanvasLayer

@export var inventory_panel: Control
@export var skill_tree_panel: Control
@export var quest_log_panel: Control
@export var dialogue_panel: Control
@export var pause_menu: Control
@export var hud: HUD

var panels: Array[Control] = []
var input_locked_by_dialogue := false

func _ready() -> void:
    panels = [inventory_panel, skill_tree_panel, quest_log_panel, pause_menu]
    for panel in panels:
        if panel: panel.visible = false
    if dialogue_panel: dialogue_panel.visible = false

func bind_runtime(player: Node, inventory: InventoryGrid, quest_manager: QuestManager, dialogue_manager: DialogueManager) -> void:
    if hud: hud.bind_player(player)
    if inventory_panel and "bind_inventory" in inventory_panel: inventory_panel.bind_inventory(inventory)
    if skill_tree_panel and "bind_player" in skill_tree_panel: skill_tree_panel.bind_player(player)
    if quest_log_panel and "bind_quest_manager" in quest_log_panel: quest_log_panel.bind_quest_manager(quest_manager)
    if dialogue_panel and "bind_dialogue_manager" in dialogue_panel: dialogue_panel.bind_dialogue_manager(dialogue_manager)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("inventory"):
        toggle_panel(inventory_panel)
    elif event.is_action_pressed("skill_tree"):
        toggle_panel(skill_tree_panel)
    elif event.is_action_pressed("quest_log"):
        toggle_panel(quest_log_panel)
    elif event.is_action_pressed("pause"):
        toggle_panel(pause_menu)

func toggle_panel(panel: Control) -> void:
    if panel == null or input_locked_by_dialogue: return
    var new_state := not panel.visible
    if new_state:
        close_all_non_modal()
    panel.visible = new_state
    get_tree().paused = any_menu_open()

func close_all_non_modal() -> void:
    for panel in panels:
        if panel: panel.visible = false

func any_menu_open() -> bool:
    for panel in panels:
        if panel and panel.visible: return true
    return false
