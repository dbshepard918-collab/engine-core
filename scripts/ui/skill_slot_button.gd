class_name SkillSlotButton
extends Button

@export var skill_icon: TextureRect
@export var cooldown_overlay: TextureProgressBar
@export var key_label: Label
@export var locked_overlay: Control

var skill: SkillDefinition
var slot_index := -1

func bind_skill(in_skill: SkillDefinition, index: int, input_label: String) -> void:
    skill = in_skill
    slot_index = index
    key_label.text = input_label
    skill_icon.texture = skill.icon if skill else null
    tooltip_text = skill.display_name + "\n" + skill.description if skill else "Locked"
    locked_overlay.visible = skill == null

func set_cooldown(remaining: float, maximum: float) -> void:
    if maximum <= 0.0:
        cooldown_overlay.value = 0.0
        disabled = false
        return
    cooldown_overlay.max_value = maximum
    cooldown_overlay.value = remaining
    disabled = remaining > 0.0 or skill == null
    text = str(ceil(remaining)) if remaining > 0.0 else ""
