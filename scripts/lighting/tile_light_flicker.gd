class_name TileLightFlicker
extends Node

@export var base_energy: float = 1.0
@export var amount: float = 0.15
@export var speed: float = 8.0
var t := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    t = rng.randf_range(0.0, 10.0)

func _process(delta: float) -> void:
    var light := get_parent() as Light3D
    if light == null: return
    t += delta * speed
    var wave := sin(t) * 0.5 + sin(t * 2.17) * 0.25 + rng.randf_range(-0.05, 0.05)
    light.light_energy = maxf(0.0, base_energy + wave * amount)
