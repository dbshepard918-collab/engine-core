class_name DynamicLightingZone
extends Area3D

signal lighting_zone_entered(zone_id: String)
signal lighting_zone_exited(zone_id: String)
signal boss_phase_lighting_applied(zone_id: String, phase_index: int)

@export var profile: DynamicLightingZoneProfile
@export var affect_group: String = "tile_dynamic_lights"
@export var player_group: String = "player"
@export var auto_connect: bool = true
var active := false
var tracked_lights: Array[Light3D] = []
var original_energy := {}
var original_color := {}

func _ready() -> void:
    monitoring = true
    monitorable = true
    if auto_connect:
        body_entered.connect(_on_body_entered)
        body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group(player_group):
        apply_zone()
        lighting_zone_entered.emit(profile.id if profile else name)

func _on_body_exited(body: Node) -> void:
    if body.is_in_group(player_group):
        restore_zone()
        lighting_zone_exited.emit(profile.id if profile else name)

func apply_zone() -> void:
    if profile == null: return
    active = true
    tracked_lights = collect_lights()
    var count := 0
    for light in tracked_lights:
        if count >= profile.max_active_lights:
            light.visible = false
            continue
        if not original_energy.has(light): original_energy[light] = light.light_energy
        if not original_color.has(light): original_color[light] = light.light_color
        light.visible = true
        light.light_color = profile.accent_color
        light.light_energy = float(original_energy[light]) * profile.light_energy_multiplier
        light.shadow_enabled = profile.enable_shadows
        count += 1

func restore_zone() -> void:
    active = false
    for light in tracked_lights:
        if not is_instance_valid(light): continue
        if original_energy.has(light): light.light_energy = original_energy[light]
        if original_color.has(light): light.light_color = original_color[light]
    tracked_lights.clear()

func apply_boss_phase(phase_index: int) -> void:
    if profile == null: return
    apply_zone()
    if phase_index >= 0 and phase_index < profile.boss_phase_color_overrides.size():
        for light in tracked_lights:
            if is_instance_valid(light): light.light_color = profile.boss_phase_color_overrides[phase_index]
    boss_phase_lighting_applied.emit(profile.id, phase_index)

func collect_lights() -> Array[Light3D]:
    var out: Array[Light3D] = []
    for node in get_tree().get_nodes_in_group(affect_group):
        if node is Light3D and global_position.distance_to(node.global_position) <= get_zone_radius_estimate():
            out.append(node)
    return out

func get_zone_radius_estimate() -> float:
    for child in get_children():
        if child is CollisionShape3D and child.shape is BoxShape3D:
            var size := (child.shape as BoxShape3D).size
            return max(size.x, size.z) * 0.75
        if child is CollisionShape3D and child.shape is SphereShape3D:
            return (child.shape as SphereShape3D).radius
    return 48.0
