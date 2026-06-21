class_name Hitbox
extends Area3D
@export var owner_node: Node
@export var source_stats: StatBlock
@export var faction: String = "player"
@export var damage_type: DamagePacket.DamageType = DamagePacket.DamageType.PHYSICAL
@export var base_multiplier: float = 1.0
@export var one_hit_per_activation: bool = true
var _already_hit: Dictionary = {}
var _active := false
func _ready() -> void:
    area_entered.connect(_on_area_entered); monitoring = false
func activate(duration: float = 0.15) -> void:
    _already_hit.clear(); _active = true; monitoring = true
    await get_tree().create_timer(duration).timeout
    monitoring = false; _active = false
func _on_area_entered(area: Area3D) -> void:
    if not _active or not area is Hurtbox: return
    var hurt := area as Hurtbox
    if hurt.faction == faction: return
    if one_hit_per_activation and _already_hit.has(hurt): return
    _already_hit[hurt] = true
    var packet := DamagePacket.create(owner_node if owner_node else self, roll_damage(), damage_type, ["melee"])
    packet.hit_position = hurt.global_position
    hurt.receive_hit(packet)
func roll_damage() -> float:
    if source_stats == null: return 1.0
    var rng := RandomNumberGenerator.new()
    var base := rng.randf_range(source_stats.weapon_damage_min, source_stats.weapon_damage_max) * base_multiplier
    if rng.randf() < clampf(source_stats.crit_chance, 0.0, 1.0): base *= source_stats.crit_multiplier
    return base
