class_name SkillTreeDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var nodes: Array[SkillTreeNodeDefinition] = []

func get_node_def(node_id: String) -> SkillTreeNodeDefinition:
    for n in nodes:
        if n.id == node_id: return n
    return null
