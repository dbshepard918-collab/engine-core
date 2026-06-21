class_name IsometricCameraRig
extends Node3D

@export var target: Node3D
@export var camera: Camera3D
@export var follow_speed: float = 9.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 8.0
@export var max_zoom: float = 18.0
@export var default_zoom: float = 12.0
@export var yaw_degrees: float = 45.0
@export var pitch_degrees: float = -55.0
@export var screen_shake_decay: float = 12.0

var _zoom := 12.0
var _shake := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _zoom = default_zoom
    rotation_degrees = Vector3(pitch_degrees, yaw_degrees, 0.0)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed: _zoom = maxf(min_zoom, _zoom - zoom_speed)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed: _zoom = minf(max_zoom, _zoom + zoom_speed)

func _process(delta: float) -> void:
    if target: global_position = global_position.lerp(target.global_position, clampf(follow_speed * delta, 0.0, 1.0))
    if camera:
        camera.position = Vector3(0, 0, _zoom)
        if _shake > 0.0:
            camera.h_offset = _rng.randf_range(-_shake, _shake)
            camera.v_offset = _rng.randf_range(-_shake, _shake)
            _shake = maxf(0.0, _shake - screen_shake_decay * delta)
        else:
            camera.h_offset = 0.0; camera.v_offset = 0.0

func add_shake(amount: float) -> void:
    _shake = maxf(_shake, amount)

