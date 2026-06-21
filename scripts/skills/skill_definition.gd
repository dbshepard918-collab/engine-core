class_name SkillDefinition
extends Resource

enum TargetingMode { SELF, AIM_DIRECTION, GROUND_POINT, TARGET_ACTOR }
@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var target_mode: TargetingMode = TargetingMode.AIM_DIRECTION
@export var cooldown: float = 1.0
@export var energy_cost: float = 0.0
@export var range: float = 8.0
@export var damage_multiplier: float = 1.0
@export var damage_type: DamagePacket.DamageType = DamagePacket.DamageType.PHYSICAL
@export var projectile_scene: PackedScene
@export var area_scene: PackedScene
@export var cast_time: float = 0.0
@export var tags: Array[String] = []
