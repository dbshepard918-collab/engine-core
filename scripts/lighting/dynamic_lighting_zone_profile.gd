class_name DynamicLightingZoneProfile
extends Resource

enum ZoneMode { ADDITIVE, OVERRIDE, BOSS_PHASE, ALERT, SAFE_HUB }

@export var id: String
@export var zone_mode: ZoneMode = ZoneMode.ADDITIVE
@export var ambient_color: Color = Color(0.02, 0.04, 0.08, 1.0)
@export var accent_color: Color = Color(0.0, 0.85, 1.0, 1.0)
@export var light_energy_multiplier: float = 1.0
@export var enable_flicker: bool = true
@export var reduce_flicker_when_accessibility_enabled: bool = true
@export var enable_shadows: bool = false
@export var max_active_lights: int = 8
@export var fade_in_time: float = 0.75
@export var fade_out_time: float = 0.5
@export var boss_phase_color_overrides: Array[Color] = []
@export_multiline var notes: String
