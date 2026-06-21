class_name Hurtbox
extends Area3D
@export var health_component: HealthComponent
@export var faction: String = "neutral"
func receive_hit(packet: DamagePacket) -> void:
    if health_component: health_component.apply_damage(packet)
