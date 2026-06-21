class_name TileDynamicLightSpawner
extends Node3D

@export var profile: TileDynamicLightProfile
@export var auto_spawn_on_ready: bool = true
@export var socket_tag: String = "light"
var spawned_lights: Array[Light3D] = []

func _ready() -> void:
    if auto_spawn_on_ready:
        spawn_lights()

func spawn_lights() -> void:
    clear_lights()
    if profile == null:
        return
    var sockets := find_light_sockets()
    var count := 0
    for socket in sockets:
        if count >= profile.max_instances_per_chunk: break
        var light := create_light()
        add_child(light)
        light.global_transform = socket.global_transform
        light.add_to_group("tile_dynamic_lights")
        spawned_lights.append(light)
        count += 1

func find_light_sockets() -> Array[Node3D]:
    var out: Array[Node3D] = []
    for node in get_parent().find_children("*", "PlacementSocket", true, false):
        var socket := node as PlacementSocket
        if socket and socket.has_tag(socket_tag): out.append(socket)
    if out.is_empty(): out.append(self)
    return out

func create_light() -> Light3D:
    var light: Light3D
    if profile.light_kind == TileDynamicLightProfile.LightKind.SPOT:
        var s := SpotLight3D.new()
        s.spot_angle = profile.spot_angle
        s.spot_range = profile.range
        light = s
    else:
        var o := OmniLight3D.new()
        o.omni_range = profile.range
        light = o
    light.light_color = profile.color
    light.light_energy = profile.energy
    light.shadow_enabled = profile.shadow_enabled
    light.distance_fade_enabled = profile.distance_fade_enabled
    light.distance_fade_begin = profile.distance_fade_begin
    light.distance_fade_length = profile.distance_fade_length
    if profile.flicker_enabled:
        var flicker := TileLightFlicker.new()
        flicker.base_energy = profile.energy
        flicker.amount = profile.flicker_amount
        flicker.speed = profile.flicker_speed
        light.add_child(flicker)
    return light

func clear_lights() -> void:
    for l in spawned_lights:
        if is_instance_valid(l): l.queue_free()
    spawned_lights.clear()
