class_name AbilityController
extends Node
signal skill_started(skill: SkillDefinition)
signal skill_finished(skill: SkillDefinition)
signal cooldown_changed(skill_id: String, remaining: float, maximum: float)
@export var actor: CharacterBody3D
@export var actor_stats: StatBlock
@export var skill_slots: Array[SkillDefinition] = []
@export var projectile_spawn: Node3D
@export var aim_camera: Camera3D
@export var ground_mask: int = 1
var cooldowns: Dictionary = {}
var energy: float = 100.0
var is_casting := false
func _ready() -> void:
    if actor_stats: energy = actor_stats.max_energy
    for s in skill_slots:
        if s: cooldowns[s.id] = 0.0
func _process(delta: float) -> void:
    for id in cooldowns.keys():
        cooldowns[id] = maxf(0.0, cooldowns[id] - delta)
        var skill := _get_skill_by_id(id)
        cooldown_changed.emit(id, cooldowns[id], skill.cooldown if skill else 1.0)
func input_slot(slot_index: int) -> void:
    if slot_index >= 0 and slot_index < skill_slots.size(): cast(skill_slots[slot_index])
func cast(skill: SkillDefinition) -> void:
    if skill == null or is_casting or cooldowns.get(skill.id, 0.0) > 0.0 or energy < skill.energy_cost: return
    energy -= skill.energy_cost; is_casting = true; skill_started.emit(skill)
    if skill.cast_time > 0.0: await get_tree().create_timer(skill.cast_time).timeout
    execute_skill(skill)
    cooldowns[skill.id] = skill.cooldown * (1.0 - clampf(actor_stats.cooldown_reduction, 0.0, 0.8))
    is_casting = false; skill_finished.emit(skill)
func execute_skill(skill: SkillDefinition) -> void:
    match skill.target_mode:
        SkillDefinition.TargetingMode.SELF: spawn_area(skill, actor.global_position)
        SkillDefinition.TargetingMode.GROUND_POINT: spawn_area(skill, get_mouse_ground_point())
        SkillDefinition.TargetingMode.AIM_DIRECTION: spawn_projectile(skill, get_aim_direction())
        SkillDefinition.TargetingMode.TARGET_ACTOR: spawn_projectile(skill, get_aim_direction())
func spawn_projectile(skill: SkillDefinition, dir: Vector3) -> void:
    if skill.projectile_scene == null: return
    var p := skill.projectile_scene.instantiate(); get_tree().current_scene.add_child(p)
    p.global_position = projectile_spawn.global_position if projectile_spawn else actor.global_position + Vector3.UP
    if "setup" in p: p.setup(actor, actor_stats, skill, dir)
func spawn_area(skill: SkillDefinition, where: Vector3) -> void:
    if skill.area_scene == null: return
    var a := skill.area_scene.instantiate(); get_tree().current_scene.add_child(a); a.global_position = where
    if "setup" in a: a.setup(actor, actor_stats, skill)
func get_aim_direction() -> Vector3:
    var point := get_mouse_ground_point(); var dir := actor.global_position.direction_to(point); dir.y = 0.0
    return dir.normalized() if dir.length_squared() > 0.001 else -actor.global_transform.basis.z
func get_mouse_ground_point() -> Vector3:
    if aim_camera == null: return actor.global_position + -actor.global_transform.basis.z * 5.0
    var mouse := get_viewport().get_mouse_position(); var from := aim_camera.project_ray_origin(mouse)
    var to := from + aim_camera.project_ray_normal(mouse) * 1000.0
    var q := PhysicsRayQueryParameters3D.create(from, to, ground_mask)
    var hit := actor.get_world_3d().direct_space_state.intersect_ray(q)
    return hit.position if hit.has("position") else actor.global_position
func _get_skill_by_id(id: String) -> SkillDefinition:
    for s in skill_slots:
        if s and s.id == id: return s
    return null
