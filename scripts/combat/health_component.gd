class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal shield_changed(current: float, maximum: float)
signal died(payload: Dictionary)
signal damaged(packet: DamagePacket, final_amount: float)

@export var owner_stats: StatBlock
@export var invulnerable: bool = false

var current_health: float
var current_shield: float

func _ready() -> void: reset_to_full()
func reset_to_full() -> void:
    current_health = owner_stats.max_health if owner_stats else 1.0
    current_shield = owner_stats.shield if owner_stats else 0.0
    health_changed.emit(current_health, get_max_health())
    shield_changed.emit(current_shield, get_max_shield())
func get_max_health() -> float: return owner_stats.max_health if owner_stats else 1.0
func get_max_shield() -> float: return owner_stats.shield if owner_stats else 0.0

func apply_damage(packet: DamagePacket) -> float:
    if invulnerable or packet.amount <= 0.0: return 0.0
    var amount := mitigate(packet)
    var shield_damage := minf(current_shield, amount)
    current_shield -= shield_damage; amount -= shield_damage
    current_health = maxf(0.0, current_health - amount)
    shield_changed.emit(current_shield, get_max_shield()); health_changed.emit(current_health, get_max_health())
    damaged.emit(packet, shield_damage + amount)
    EventBus.emit_damage({"target": get_parent(), "packet": packet, "final": shield_damage + amount})
    if current_health <= 0.0: died.emit({"killer": packet.source, "packet": packet})
    return shield_damage + amount

func mitigate(packet: DamagePacket) -> float:
    if packet.type == DamagePacket.DamageType.TRUE: return packet.amount
    var armor_reduction := 100.0 / (100.0 + maxf(0.0, owner_stats.armor))
    var resist := 0.0
    match packet.type:
        DamagePacket.DamageType.SHOCK: resist = owner_stats.shock_resist
        DamagePacket.DamageType.BURN: resist = owner_stats.burn_resist
        DamagePacket.DamageType.VIRAL: resist = owner_stats.viral_resist
        DamagePacket.DamageType.NEON: resist = owner_stats.neon_resist
        _: resist = 0.0
    resist = clampf(resist, -0.75, 0.85)
    return maxf(1.0, packet.amount * armor_reduction * (1.0 - resist))

func heal(amount: float) -> void:
    current_health = minf(get_max_health(), current_health + amount)
    health_changed.emit(current_health, get_max_health())
