class_name AtlasSpriteBillboard
extends Sprite3D

@export var frames: Array[Texture2D] = []
@export var frame_rate: float = 8.0
@export var face_camera: bool = true
var idx := 0
var timer := 0.0

func _process(delta: float) -> void:
    if face_camera:
        var cam := get_viewport().get_camera_3d()
        if cam: look_at(cam.global_position, Vector3.UP)
    if frames.is_empty(): return
    timer += delta
    if timer >= 1.0 / frame_rate:
        timer = 0.0
        idx = (idx + 1) % frames.size()
        texture = frames[idx]
