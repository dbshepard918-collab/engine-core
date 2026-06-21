class_name StatBlock
extends Resource

@export var max_health: float = 100.0
@export var max_energy: float = 100.0
@export var weapon_damage_min: float = 5.0
@export var weapon_damage_max: float = 8.0
@export var tech_power: float = 0.0
@export var armor: float = 0.0
@export var shield: float = 0.0
@export var crit_chance: float = 0.05
@export var crit_multiplier: float = 1.5
@export var attack_speed: float = 1.0
@export var cooldown_reduction: float = 0.0
@export var move_speed: float = 6.0
@export var neon_resist: float = 0.0
@export var shock_resist: float = 0.0
@export var burn_resist: float = 0.0
@export var viral_resist: float = 0.0

func duplicate_block() -> StatBlock:
    var s := StatBlock.new()
    s.max_health = max_health; s.max_energy = max_energy
    s.weapon_damage_min = weapon_damage_min; s.weapon_damage_max = weapon_damage_max
    s.tech_power = tech_power; s.armor = armor; s.shield = shield
    s.crit_chance = crit_chance; s.crit_multiplier = crit_multiplier
    s.attack_speed = attack_speed; s.cooldown_reduction = cooldown_reduction; s.move_speed = move_speed
    s.neon_resist = neon_resist; s.shock_resist = shock_resist; s.burn_resist = burn_resist; s.viral_resist = viral_resist
    return s

func add(other: StatBlock) -> void:
    if other == null: return
    max_health += other.max_health; max_energy += other.max_energy
    weapon_damage_min += other.weapon_damage_min; weapon_damage_max += other.weapon_damage_max
    tech_power += other.tech_power; armor += other.armor; shield += other.shield
    crit_chance += other.crit_chance; crit_multiplier += other.crit_multiplier
    attack_speed += other.attack_speed; cooldown_reduction += other.cooldown_reduction; move_speed += other.move_speed
    neon_resist += other.neon_resist; shock_resist += other.shock_resist; burn_resist += other.burn_resist; viral_resist += other.viral_resist
