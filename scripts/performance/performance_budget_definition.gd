class_name PerformanceBudgetDefinition
extends Resource

@export var id: String
@export var target_fps: int = 60
@export var max_frame_ms: float = 16.67
@export var max_draw_calls: int = 1800
@export var max_visible_enemies: int = 45
@export var max_active_projectiles: int = 160
@export var max_active_particles: int = 120
@export var max_visible_lights: int = 32
@export var max_texture_memory_mb: int = 2048
@export var max_audio_voices: int = 64
@export var district_stream_radius: int = 2
@export var use_occlusion_culling: bool = true
@export var use_lod: bool = true
