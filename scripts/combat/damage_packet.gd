class_name DamagePacket
extends Resource

enum DamageType { PHYSICAL, SHOCK, BURN, VIRAL, NEON, TRUE }

@export var source: NodePath
@export var amount: float = 0.0
@export var type: DamageType = DamageType.PHYSICAL
@export var can_crit: bool = true
@export var is_crit: bool = false
@export var stagger: float = 0.0
@export var hit_position: Vector3 = Vector3.ZERO
@export var tags: Array[String] = []

static func create(source_node: Node, base_amount: float, damage_type: DamageType, in_tags: Array[String] = []) -> DamagePacket:
    var p := DamagePacket.new()
    p.source = source_node.get_path()
    p.amount = base_amount
    p.type = damage_type
    p.tags = in_tags
    return p
