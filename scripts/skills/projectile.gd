class_name SkillProjectile
extends Area3D
@export var speed: float = 18.0
@export var lifetime: float = 2.0
@export var faction: String = "player"
@export var pierce_count: int = 0
var source: Node
var source_stats: StatBlock
var skill: SkillDefinition
var direction := Vector3.FORWARD
var hits := 0
var alive := true
func setup(in_source: Node, in_stats: StatBlock, in_skill: SkillDefinition, in_dir: Vector3) -> void:
    source = in_source; source_stats = in_stats; skill = in_skill; direction = in_dir.normalized(); look_at(global_position + direction, Vector3.UP)
func _ready() -> void:
    area_entered.connect(_on_area_entered)
    await get_tree().create_timer(lifetime).timeout
    if alive: queue_free()
func _physics_process(delta: float) -> void: global_position += direction * speed * delta
func _on_area_entered(area: Area3D) -> void:
    if not area is Hurtbox: return
    var hurt := area as Hurtbox
    if hurt.faction == faction: return
    var base := randf_range(source_stats.weapon_damage_min, source_stats.weapon_damage_max) + source_stats.tech_power
    var packet := DamagePacket.create(source, base * skill.damage_multiplier, skill.damage_type, skill.tags)
    packet.hit_position = global_position; hurt.receive_hit(packet)
    hits += 1
    if hits > pierce_count: alive = false; queue_free()

