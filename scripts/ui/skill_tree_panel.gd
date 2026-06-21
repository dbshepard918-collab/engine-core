class_name SkillTreePanel
extends Control

@export var points_label: Label
@export var node_container: Control
@export var connection_lines: Control
@export var node_button_scene: PackedScene
@export var detail_name: Label
@export var detail_description: RichTextLabel
@export var rank_label: Label
@export var purchase_button: Button
@export var refund_button: Button

var tree: PlayerSkillTree
var selected_node_id := ""
var buttons := {}

func bind_player(player: Node) -> void:
    tree = player.get_node_or_null("PlayerSkillTree") as PlayerSkillTree
    if tree == null: return
    tree.node_rank_changed.connect(_on_node_rank_changed)
    tree.skill_points_changed.connect(_on_points_changed)
    purchase_button.pressed.connect(func(): if selected_node_id != "": tree.purchase(selected_node_id))
    refund_button.pressed.connect(func(): if selected_node_id != "": tree.refund(selected_node_id))
    build_graph()

func build_graph() -> void:
    for c in node_container.get_children(): c.queue_free()
    buttons.clear()
    for node_def in tree.tree_definition.nodes:
        var b := node_button_scene.instantiate() as Button
        b.position = node_def.position
        b.text = node_def.display_name
        b.icon = node_def.icon
        b.pressed.connect(func(id = node_def.id): select_node(id))
        node_container.add_child(b)
        buttons[node_def.id] = b
    _on_points_changed(tree.available_points)

func select_node(node_id: String) -> void:
    selected_node_id = node_id
    var def := tree.tree_definition.get_node_def(node_id)
    detail_name.text = def.display_name
    detail_description.bbcode_enabled = true
    detail_description.text = def.description
    rank_label.text = "Rank %d / %d" % [int(tree.ranks.get(node_id, 0)), def.max_rank]
    purchase_button.disabled = not tree.can_purchase(node_id)
    refund_button.disabled = int(tree.ranks.get(node_id, 0)) <= 0 or tree.has_dependents(node_id)

func _on_node_rank_changed(node_id: String, rank: int) -> void:
    if buttons.has(node_id):
        buttons[node_id].text = tree.tree_definition.get_node_def(node_id).display_name + " " + str(rank)
    if selected_node_id == node_id: select_node(node_id)

func _on_points_changed(points: int) -> void:
    points_label.text = "Skill Points: " + str(points)
