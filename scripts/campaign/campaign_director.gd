extends Node

signal act_changed(act_id: String)
signal district_unlocked(district_id: String)
signal campaign_flag_changed(flag: String, value)

@export var acts: Array[CampaignActDefinition] = []
@export var quest_manager: QuestManager
@export var campaign_state: CampaignState

var acts_by_id := {}

func _ready() -> void:
    for act in acts:
        acts_by_id[act.id] = act
    if quest_manager:
        quest_manager.quest_completed.connect(_on_quest_completed)

func get_current_act() -> CampaignActDefinition:
    return acts_by_id.get(campaign_state.current_act_id)

func set_flag(flag: String, value) -> void:
    campaign_state.global_flags[flag] = value
    campaign_flag_changed.emit(flag, value)

func can_advance_to(act_id: String) -> bool:
    var act: CampaignActDefinition = acts_by_id.get(act_id)
    if act == null: return false
    for qid in act.required_quest_ids:
        if not quest_manager.completed_quests.has(qid): return false
    return true

func advance_to(act_id: String) -> bool:
    if not can_advance_to(act_id): return false
    if not campaign_state.completed_act_ids.has(campaign_state.current_act_id):
        campaign_state.completed_act_ids.append(campaign_state.current_act_id)
    campaign_state.current_act_id = act_id
    var act := get_current_act()
    for district in act.unlock_district_ids:
        unlock_district(district)
    for tier in act.unlock_crafting_tiers:
        if not campaign_state.unlocked_crafting_tiers.has(tier): campaign_state.unlocked_crafting_tiers.append(tier)
    for qid in act.unlock_quest_ids:
        quest_manager.start_quest(qid)
    act_changed.emit(act_id)
    return true

func unlock_district(district_id: String) -> void:
    if campaign_state.unlocked_district_ids.has(district_id): return
    campaign_state.unlocked_district_ids.append(district_id)
    district_unlocked.emit(district_id)

func _on_quest_completed(quest_id: String) -> void:
    for act_id in acts_by_id.keys():
        if act_id != campaign_state.current_act_id and can_advance_to(act_id):
            advance_to(act_id)
            return
