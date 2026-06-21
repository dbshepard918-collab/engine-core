class_name EnemyController
extends CharacterBody3D

enum State { IDLE, PATROL, CHASE, ATTACK, RECOVER, STUNNED, DEAD }
@export var stats: StatBlock
@export var health: HealthComponent
@export var nav_agent: NavigationAgent3D
@export var hurtbox: Hurtbox
@export var attack_hitbox: Hitbox
@export var aggro_range: float = 12.0
@export var leash_range: float = 28.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.35
@export var windup_time: float = 0.28
@export var recovery_time: float = 0.45
@export var patrol_points: Array[NodePath] = []
var state: State = State.IDLE
var target: Node3D
var spawn_position: Vector3
var attack_cd := 0.0
var patrol_index := 0
func _ready() -> void:
    spawn_position = global_position
    if health: health.died.connect(_on_died)
    change_state(State.IDLE)
func _physics_process(delta: float) -> void:
    if state == State.DEAD: return
    attack_cd = maxf(0.0, attack_cd - delta); acquire_target()
    match state:
        State.IDLE: tick_idle(delta)
        State.PATROL: tick_patrol(delta)
        State.CHASE: tick_chase(delta)
        State.ATTACK: pass
        State.RECOVER: pass
        State.STUNNED: pass
func acquire_target() -> void:
    var player := get_tree().get_first_node_in_group("player") as Node3D
    if player == null: return
    var d := global_position.distance_to(player.global_position)
    if target == null and d <= aggro_range: target = player; change_state(State.CHASE)
    elif target != null and global_position.distance_to(spawn_position) > leash_range:
        target = null; nav_agent.target_position = spawn_position; change_state(State.PATROL)
func tick_idle(delta: float) -> void:
    velocity = velocity.move_toward(Vector3.ZERO, stats.move_speed * 4.0 * delta); move_and_slide()
    if not patrol_points.is_empty(): change_state(State.PATROL)
func tick_patrol(delta: float) -> void:
    if patrol_points.is_empty(): change_state(State.IDLE); return
    var p_node := get_node_or_null(patrol_points[patrol_index]) as Node3D
    if p_node == null: return
    nav_agent.target_position = p_node.global_position; move_with_nav(delta, stats.move_speed * 0.6)
    if global_position.distance_to(p_node.global_position) < 0.5: patrol_index = (patrol_index + 1) % patrol_points.size()
func tick_chase(delta: float) -> void:
    if target == null: change_state(State.IDLE); return
    var dist := global_position.distance_to(target.global_position)
    if dist <= attack_range and attack_cd <= 0.0: start_attack(); return
    nav_agent.target_position = target.global_position; move_with_nav(delta, stats.move_speed)
func move_with_nav(delta: float, speed: float) -> void:
    if nav_agent.is_navigation_finished(): return
    var next := nav_agent.get_next_path_position(); var dir := global_position.direction_to(next); dir.y = 0
    velocity = dir.normalized() * speed; move_and_slide()
    if dir.length_squared() > 0.001: rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), delta * 10.0)
func start_attack() -> void:
    change_state(State.ATTACK); attack_cd = attack_cooldown; velocity = Vector3.ZERO
    await get_tree().create_timer(windup_time).timeout
    if state != State.ATTACK: return
    if attack_hitbox: attack_hitbox.activate(0.15)
    await get_tree().create_timer(recovery_time).timeout
    if state != State.DEAD: change_state(State.CHASE)
func change_state(next: State) -> void: state = next
func _on_died(payload: Dictionary) -> void:
    change_state(State.DEAD); collision_layer = 0; collision_mask = 0
    if hurtbox: hurtbox.monitorable = false
    EventBus.emit_enemy_killed(self, payload); queue_free()
