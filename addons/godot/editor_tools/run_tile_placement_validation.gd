@tool
extends EditorScript

func _run() -> void:
    var root := get_scene()
    if root == null:
        push_error("Open a scene with a TilePlacementValidator node.")
        return
    var validators := root.find_children("*", "TilePlacementValidator", true, false)
    if validators.is_empty():
        push_error("No TilePlacementValidator found in current scene.")
        return
    for v in validators:
        v.print_report()
