class_name PuzzleLightingZoneController
extends Node

signal puzzle_lighting_state_changed(state_id: String)

@export var puzzle_room_generator: ProceduralPuzzleRoomGenerator
@export var active_zone: DynamicLightingZone
@export var solved_zone: DynamicLightingZone
@export var error_zone: DynamicLightingZone
@export var auto_connect: bool = true

func _ready() -> void:
    if auto_connect and puzzle_room_generator:
        puzzle_room_generator.puzzle_room_started.connect(_on_puzzle_started)
        puzzle_room_generator.puzzle_room_solved.connect(_on_puzzle_solved)

func _on_puzzle_started(room_id: String) -> void:
    if active_zone: active_zone.apply_zone()
    puzzle_lighting_state_changed.emit("active")

func _on_puzzle_solved(room_id: String) -> void:
    if active_zone: active_zone.restore_zone()
    if solved_zone: solved_zone.apply_zone()
    puzzle_lighting_state_changed.emit("solved")

func apply_error_flash() -> void:
    if error_zone: error_zone.apply_zone()
    puzzle_lighting_state_changed.emit("error")
