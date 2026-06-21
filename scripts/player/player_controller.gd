class_name PlayerController
extends CharacterBody3D

@export var stats: StatBlock
@export var camera: Camera3D
@export var nav_agent: NavigationAgent3D
@export var model_root: Node3D
@export var ground_mask: int = 1
@export var rotation_speed: float = 16.0
@export var click_stop_distance: float = 0.25
@export var dash_speed: float = 18.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 1.15

var _click_move_enabled := false
var _dash_timer := 0.0
var _dash_cd_timer := 0.0
var _dash_dir := Vector3.ZERO
var _last_non_zero_dir := Vector3.FORWARD

func _ready() -> void:
    assert(stats != null)
    assert(nav_agent != null)
    nav_agent.velocity_computed.connect(_on_velocity_computed)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if not Input.is_action_pressed("primary_attack"):
            set_click_target_from_mouse()

func _physics_process(delta: float) -> void:
    _dash_cd_timer = maxf(0.0, _dash_cd_timer - delta)
    if _dash_timer > 0.0:
        _dash_timer -= delta
        velocity = _dash_dir * dash_speed
        move_and_slide()
        _face_direction(_dash_dir, delta)
        return
    if Input.is_action_just_pressed("dash"): try_dash()
    var direct := _get_direct_input_direction()
    if direct.length_squared() > 0.001:
        _click_move_enabled = false
        _last_non_zero_dir = direct.normalized()
        velocity = direct.normalized() * stats.move_speed
        move_and_slide()
        _face_direction(direct, delta)
        return
    if _click_move_enabled:
        if nav_agent.is_navigation_finished() or global_position.distance_to(nav_agent.target_position) <= click_stop_distance:
            _click_move_enabled = false; velocity = Vector3.ZERO; move_and_slide(); return
        var next_pos := nav_agent.get_next_path_position()
        var desired := global_position.direction_to(next_pos); desired.y = 0.0
        nav_agent.velocity = desired.normalized() * stats.move_speed
    else:
        velocity = velocity.move_toward(Vector3.ZERO, stats.move_speed * 8.0 * delta)
        move_and_slide()

func _get_direct_input_direction() -> Vector3:
    var x := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    var z := Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
    var dir := Vector3(x, 0, z)
    if camera:
        var basis := camera.global_transform.basis
        var cam_forward := -basis.z; cam_forward.y = 0; cam_forward = cam_forward.normalized()
        var cam_right := basis.x; cam_right.y = 0; cam_right = cam_right.normalized()
        dir = cam_right * x + cam_forward * -z
    return dir.normalized() if dir.length_squared() > 1.0 else dir

func set_click_target_from_mouse() -> void:
    if camera == null: return
    var mouse := get_viewport().get_mouse_position()
    var from := camera.project_ray_origin(mouse)
    var to := from + camera.project_ray_normal(mouse) * 1000.0
    var query := PhysicsRayQueryParameters3D.create(from, to, ground_mask)
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.has("position"):
        nav_agent.target_position = hit.position
        _click_move_enabled = true

func try_dash() -> void:
    if _dash_cd_timer > 0.0: return
    _dash_dir = _get_direct_input_direction()
    if _dash_dir.length_squared() < 0.001: _dash_dir = _last_non_zero_dir
    _dash_dir = _dash_dir.normalized(); _dash_timer = dash_duration; _dash_cd_timer = dash_cooldown

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    if not _click_move_enabled: return
    velocity = safe_velocity; move_and_slide(); _face_direction(safe_velocity, get_physics_process_delta_time())

func _face_direction(dir: Vector3, delta: float) -> void:
    if model_root == null or dir.length_squared() < 0.001: return
    var target_yaw := atan2(dir.x, dir.z)
    model_root.rotation.y = lerp_angle(model_root.rotation.y, target_yaw, clampf(rotation_speed * delta, 0.0, 1.0))
