class_name ActorAnimationController
extends Node

@export var animation_tree: AnimationTree
@export var model_root: Node3D
@export var locomotion_blend_path: String = "parameters/Locomotion/blend_position"
@export var playback_path: String = "parameters/playback"
@export var attack_speed_scale_path: String = "parameters/AttackSpeed/scale"

var playback: AnimationNodeStateMachinePlayback
var current_state := "idle"

func _ready() -> void:
    assert(animation_tree != null)
    animation_tree.active = true
    playback = animation_tree.get(playback_path)

func set_locomotion(world_velocity: Vector3, max_speed: float) -> void:
    var speed_ratio := clampf(world_velocity.length() / maxf(max_speed, 0.01), 0.0, 1.0)
    animation_tree.set(locomotion_blend_path, speed_ratio)
    if speed_ratio < 0.05:
        travel("idle")
    elif speed_ratio < 0.55:
        travel("walk")
    else:
        travel("run")

func play_attack(combo_index: int, attack_speed: float) -> void:
    animation_tree.set(attack_speed_scale_path, attack_speed)
    match combo_index:
        0: travel("basic_attack_01")
        1: travel("basic_attack_02")
        2: travel("basic_attack_03")
        _: travel("basic_attack_01")

func play_skill(skill: SkillDefinition) -> void:
    if skill == null: return
    if skill.tags.has("channel"):
        travel("cast_channel")
    elif skill.tags.has("heavy"):
        travel("heavy_attack")
    else:
        travel("cast_fast")

func play_hit_reaction(severity: String, direction: Vector3) -> void:
    match severity:
        "heavy": travel("hit_heavy")
        "stagger": travel("stagger")
        _: travel("hit_light_front")

func play_death() -> void:
    travel("death")

func travel(state_name: String) -> void:
    if playback == null: return
    if current_state == state_name: return
    playback.travel(state_name)
    current_state = state_name
