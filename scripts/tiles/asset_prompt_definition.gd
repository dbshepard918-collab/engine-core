class_name AssetPromptDefinition
extends Resource

@export var id: String
@export var category: String
@export var output_type: String # texture, tile, sprite, icon, character_ref, prop_ref
@export_multiline var prompt: String
@export_multiline var negative_prompt: String
@export var width: int = 1024
@export var height: int = 1024
@export var seed: int = 0
@export var notes: String = ""
