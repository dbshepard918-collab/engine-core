class_name ItemTooltip
extends PanelContainer

@export var name_label: RichTextLabel
@export var type_label: Label
@export var description_label: RichTextLabel
@export var stat_list: VBoxContainer
@export var affix_line_scene: PackedScene

func show_item(item: ItemInstance, compare_stats: StatBlock = null) -> void:
    if item == null:
        visible = false
        return
    visible = true
    name_label.bbcode_enabled = true
    name_label.text = rarity_color(item.rarity) + item.build_display_name() + "[/color]"
    type_label.text = ItemDefinition.ItemType.keys()[item.definition.item_type]
    description_label.bbcode_enabled = true
    description_label.text = item.definition.description
    for child in stat_list.get_children(): child.queue_free()
    var total := item.get_total_stats()
    add_stat_line("Damage", total.weapon_damage_min, total.weapon_damage_max)
    add_stat_line("Tech Power", total.tech_power)
    add_stat_line("Armor", total.armor)
    add_stat_line("Shield", total.shield)
    add_stat_line("Crit Chance", total.crit_chance * 100.0, null, "%")
    for affix in item.rolled_affixes:
        var line := affix_line_scene.instantiate() as Label
        line.text = str(affix.get("text", ""))
        stat_list.add_child(line)

func add_stat_line(label: String, a: float, b = null, suffix: String = "") -> void:
    if a == 0 and b == null: return
    var line := affix_line_scene.instantiate() as Label
    line.text = "%s: %.1f%s" % [label, a, suffix] if b == null else "%s: %.1f-%.1f%s" % [label, a, b, suffix]
    stat_list.add_child(line)

func rarity_color(rarity: int) -> String:
    match rarity:
        ItemDefinition.Rarity.COMMON: return "[color=#d0d0d0]"
        ItemDefinition.Rarity.UNCOMMON: return "[color=#35e06f]"
        ItemDefinition.Rarity.RARE: return "[color=#36a3ff]"
        ItemDefinition.Rarity.EPIC: return "[color=#b45cff]"
        ItemDefinition.Rarity.LEGENDARY: return "[color=#ff9b2f]"
        ItemDefinition.Rarity.MYTHIC: return "[color=#ff3bd4]"
    return "[color=white]"
