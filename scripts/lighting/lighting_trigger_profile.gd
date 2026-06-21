class_name LightingTriggerProfile
extends Resource

enum TriggerMode { ON_ENTER, ON_EXIT, TOGGLE, ONE_SHOT_REWARD, LOOT_REVEAL, AMBUSH_ALERT }

@export var id: String
@export var trigger_mode: TriggerMode = TriggerMode.ON_ENTER
@export var target_group: String = "tile_dynamic_lights"
@export var color_override: Color = Color(0.0, 0.85, 1.0, 1.0)
@export var energy_multiplier: float = 1.25
@export var fade_time: float = 0.35
@export var enable_target_lights: bool = true
@export var disable_target_lights_on_exit: bool = false
@export var pulse_once: bool = false
@export var pulse_duration: float = 0.5
@export var one_shot: bool = false
@export var required_group: String = "player"
@export_multiline var notes: String
