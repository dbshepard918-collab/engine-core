
class_name ProceduralCityPromptProfile
extends Resource

@export var id: String
@export var district_id: String
@export var camera_language: String = "top-down high isometric ARPG camera"
@export var layout_keywords: Array[String] = []
@export var visual_keywords: Array[String] = []
@export var hazard_keywords: Array[String] = []
@export var required_gameplay_beats: Array[String] = []
@export_multiline var sd_map_prompt: String
@export_multiline var sd_negative_prompt: String
@export_multiline var tripo_tile_prompt: String
@export_multiline var tripo_landmark_prompt: String

func build_summary() -> String:
    return "%s | %s | %s" % [district_id, ", ".join(layout_keywords), ", ".join(visual_keywords)]
