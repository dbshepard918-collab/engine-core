class_name TileDynamicLightProfile
extends Resource

enum LightKind { OMNI, SPOT }

@export var id: String
@export var light_kind: LightKind = LightKind.OMNI
@export var color: Color = Color(0.0, 0.85, 1.0, 1.0)
@export var energy: float = 1.25
@export var range: float = 7.0
@export var spot_angle: float = 45.0
@export var shadow_enabled: bool = false
@export var distance_fade_enabled: bool = true
@export var distance_fade_begin: float = 28.0
@export var distance_fade_length: float = 12.0
@export var flicker_enabled: bool = true
@export var flicker_amount: float = 0.15
@export var flicker_speed: float = 8.0
@export var max_instances_per_chunk: int = 6
