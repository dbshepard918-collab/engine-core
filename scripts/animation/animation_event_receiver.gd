class_name AnimationEventReceiver
extends Node

@export var hitbox: Hitbox
@export var ability_controller: AbilityController
@export var audio_footstep: AudioStream
@export var melee_trail: GPUParticles3D
@export var muzzle_flash: GPUParticles3D

func anim_enable_hitbox(duration: float = 0.12) -> void:
    if hitbox: hitbox.activate(duration)

func anim_spawn_queued_projectile() -> void:
    if ability_controller and "release_queued_skill" in ability_controller:
        ability_controller.release_queued_skill()

func anim_footstep() -> void:
    AudioManager.play_sfx(audio_footstep, 0.08, -6.0)

func anim_melee_trail_on() -> void:
    if melee_trail: melee_trail.emitting = true

func anim_melee_trail_off() -> void:
    if melee_trail: melee_trail.emitting = false

func anim_muzzle_flash() -> void:
    if muzzle_flash: muzzle_flash.restart()
