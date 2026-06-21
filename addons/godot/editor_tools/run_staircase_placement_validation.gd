@tool
extends EditorScript

func _run() -> void:
    var root := get_scene()
    if root == null:
        push_error("Open a scene with StaircaseTilePlacementValidator.")
        return
    var validators := root.find_children("*", "StaircaseTilePlacementValidator", true, false)
    if validators.is_empty():
        push_error("No StaircaseTilePlacementValidator found in current scene.")
        return
    for v in validators:
        v.print_report()
