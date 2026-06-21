class_name DialoguePanel
extends Control

@export var speaker_label: Label
@export var line_label: RichTextLabel
@export var portrait_rect: TextureRect
@export var choice_container: VBoxContainer
@export var choice_button_scene: PackedScene
@export var typewriter_chars_per_second: float = 45.0

var manager: DialogueManager
var full_line := ""
var type_timer := 0.0
var revealing := false

func bind_dialogue_manager(dm: DialogueManager) -> void:
    manager = dm
    manager.dialogue_started.connect(func(id): visible = true)
    manager.dialogue_finished.connect(func(id): visible = false)
    manager.dialogue_line_changed.connect(show_line)
    manager.dialogue_choices_changed.connect(show_choices)

func show_line(node: DialogueNodeDefinition) -> void:
    speaker_label.text = node.speaker_display_name
    portrait_rect.texture = node.portrait
    full_line = node.line
    line_label.bbcode_enabled = true
    line_label.text = ""
    line_label.visible_characters = 0
    revealing = true
    type_timer = 0.0

func _process(delta: float) -> void:
    if not revealing: return
    type_timer += delta * typewriter_chars_per_second
    line_label.text = full_line
    line_label.visible_characters = int(type_timer)
    if line_label.visible_characters >= full_line.length():
        revealing = false
        line_label.visible_characters = -1

func show_choices(choices: Array[DialogueChoice]) -> void:
    for c in choice_container.get_children(): c.queue_free()
    for choice in choices:
        var b := choice_button_scene.instantiate() as Button
        b.text = choice.text
        b.pressed.connect(func(ch = choice): manager.choose(ch))
        choice_container.add_child(b)
