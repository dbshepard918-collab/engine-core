extends Camera3D

@export var target_path: NodePath
@export var follow_speed = 5.0

var target

func _ready():
	target = get_node(target_path)

func _process(delta):
	if target:
		global_position = global_position.lerp(target.global_position + Vector3(0,10,10), delta * follow_speed)
		look_at(target.global_position, Vector3.UP)
