extends Node
@export var sfx_bus: String = "SFX"
@export var music_bus: String = "Music"
@export var pool_size: int = 24
var pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
func _ready() -> void:
    for i in range(pool_size):
        var p := AudioStreamPlayer.new(); p.bus = sfx_bus; add_child(p); pool.append(p)
    music_player = AudioStreamPlayer.new(); music_player.bus = music_bus; add_child(music_player)
func play_sfx(stream: AudioStream, pitch_variation: float = 0.05, volume_db: float = 0.0) -> void:
    if stream == null: return
    var p := get_free_player(); p.stream = stream; p.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation); p.volume_db = volume_db; p.play()
func play_music(stream: AudioStream, fade_seconds: float = 1.0) -> void:
    music_player.stream = stream; music_player.play()
func get_free_player() -> AudioStreamPlayer:
    for p in pool:
        if not p.playing: return p
    return pool[0]

