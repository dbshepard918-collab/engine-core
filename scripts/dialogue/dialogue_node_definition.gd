class_name DialogueNodeDefinition
extends Resource

@export var id: String
@export var speaker_id: String
@export var speaker_display_name: String
@export_multiline var line: String
@export var portrait: Texture2D
@export var choices: Array[DialogueChoice] = []
@export var auto_advance_next_id: String = ""
@export var voice_event_id: String = ""
