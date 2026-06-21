class_name HUD
extends Control
@export var health_bar: ProgressBar
@export var shield_bar: ProgressBar
@export var energy_bar: ProgressBar
@export var skill_buttons: Array[Button] = []
@export var tooltip: Control
@export var toast_label: Label
func bind_player(player: Node) -> void:
    var health := player.get_node_or_null("HealthComponent") as HealthComponent
    if health:
        health.health_changed.connect(_on_health_changed); health.shield_changed.connect(_on_shield_changed)
    var abilities := player.get_node_or_null("AbilityController") as AbilityController
    if abilities: abilities.cooldown_changed.connect(_on_cooldown_changed)
    EventBus.ui_toast_requested.connect(_on_toast)
func _on_health_changed(current: float, maximum: float) -> void: health_bar.max_value = maximum; health_bar.value = current
func _on_shield_changed(current: float, maximum: float) -> void: shield_bar.max_value = maximum; shield_bar.value = current
func _on_cooldown_changed(skill_id: String, remaining: float, maximum: float) -> void:
    for b in skill_buttons:
        if b.get_meta("skill_id", "") == skill_id: b.text = str(ceil(remaining)) if remaining > 0.0 else b.get_meta("label", skill_id); b.disabled = remaining > 0.0
func _on_toast(message: String, style: String) -> void:
    toast_label.text = message; toast_label.visible = true
    await get_tree().create_timer(2.0).timeout
    toast_label.visible = false
