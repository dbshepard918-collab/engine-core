extends Node

signal settings_changed(settings: AccessibilitySettings)

@export var settings: AccessibilitySettings
@export var ui_root: UIMain

func apply_settings() -> void:
    if ui_root:
        ui_root.scale = Vector2(settings.ui_scale, settings.ui_scale)
    get_tree().call_group("screen_shake_receivers", "set_reduced_shake", settings.reduce_screen_shake)
    get_tree().call_group("telegraph_receivers", "set_telegraph_intensity", settings.enemy_telegraph_intensity)
    get_tree().call_group("subtitle_receivers", "set_subtitle_settings", settings)
    settings_changed.emit(settings)

func set_high_contrast(enabled: bool) -> void:
    settings.high_contrast_ui = enabled
    apply_settings()

func set_reduce_flashing(enabled: bool) -> void:
    settings.reduce_flashing = enabled
    apply_settings()

func set_ui_scale(value: float) -> void:
    settings.ui_scale = clampf(value, 0.75, 1.75)
    apply_settings()
