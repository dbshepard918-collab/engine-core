class_name PropScatterer
extends Node

@export var profiles: Array[PropScatterProfile] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()

func scatter_on_tile(tile_root: Node3D, district_tag: String = "") -> void:
    var sockets := []
    for node in tile_root.find_children("*", "PlacementSocket", true, false):
        sockets.append(node)
    for profile in profiles:
        var spawned := 0
        for s in sockets:
            if spawned >= profile.max_per_tile: break
            if s.occupied or not s.has_tag(profile.required_socket_tag): continue
            if rng.randf() > profile.spawn_chance: continue
            if profile.prop_scenes.is_empty(): continue
            var scene := profile.prop_scenes[rng.randi_range(0, profile.prop_scenes.size() - 1)]
            var prop := scene.instantiate() as Node3D
            tile_root.add_child(prop)
            prop.global_position = s.global_position
            prop.global_rotation = s.global_rotation
            if profile.random_yaw:
                prop.rotate_y(rng.randf_range(0.0, TAU))
            var sc := rng.randf_range(profile.scale_min, profile.scale_max)
            prop.scale = Vector3.ONE * sc
            s.occupied = true
            spawned += 1
