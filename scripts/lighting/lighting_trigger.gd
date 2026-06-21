class_name LightingTrigger
extends Area3D

signal lighting_trigger_activated(trigger_id: String)
signal lighting_trigger_deactivated(trigger_id: String)

@export var profile: LightingTriggerProfile
@export var trigger_radius: float = 18.0
@export var auto_connect: bool = true
var activated := false
var original_energy := {}
var original_color := {}
var original_visible := {}

func _ready() -> void:
    monitoring = true
    monitorable = true
    add_to_group("lighting_triggers")
    if auto_connect:
        body_entered.connect(_on_body_entered)
        body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
    if profile == null: return
    if body.is_in_group(profile.required_group):
        if profile.one_shot and activated: return
        if profile.trigger_mode in [LightingTriggerProfile.TriggerMode.ON_ENTER, LightingTriggerProfile.TriggerMode.TOGGLE, LightingTriggerProfile.TriggerMode.ONE_SHOT_REWARD, LightingTriggerProfile.TriggerMode.LOOT_REVEAL, LightingTriggerProfile.TriggerMode.AMBUSH_ALERT]:
            activate()

func _on_body_exited(body: Node) -> void:
    if profile == null: return
    if body.is_in_group(profile.required_group):
        if profile.trigger_mode == LightingTriggerProfile.TriggerMode.ON_EXIT:
            activate()
        elif profile.disable_target_lights_on_exit:
            deactivate()

func activate() -> void:
    if profile == null: return
    activated = true
    for light in collect_target_lights():
        remember_light(light)
        light.visible = profile.enable_target_lights
        light.light_color = profile.color_override
        light.light_energy = float(original_energy[light]) * profile.energy_multiplier
    lighting_trigger_activated.emit(profile.id)

func deactivate() -> void:
    for light in original_energy.keys():
        if not is_instance_valid(light): continue
        light.light_energy = original_energy[light]
        light.light_color = original_color[light]
        light.visible = original_visible[light]
    lighting_trigger_deactivated.emit(profile.id if profile else name)

func collect_target_lights() -> Array[Light3D]:
    var out: Array[Light3D] = []
    if profile == null: return out
    for node in get_tree().get_nodes_in_group(profile.target_group):
        if node is Light3D and global_position.distance_to(node.global_position) <= trigger_radius:
            out.append(node)
    return out

func remember_light(light: Light3D) -> void:
    if not original_energy.has(light): original_energy[light] = light.light_energy
    if not original_color.has(light): original_color[light] = light.light_color
    if not original_visible.has(light): original_visible[light] = light.visible
