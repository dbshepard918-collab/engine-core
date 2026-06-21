class_name DialogueGraphDefinition
extends Resource

@export var id: String
@export var start_node_id: String
@export var nodes: Array[DialogueNodeDefinition] = []

func get_node_def(node_id: String) -> DialogueNodeDefinition:
    for n in nodes:
        if n.id == node_id: return n
    return null
